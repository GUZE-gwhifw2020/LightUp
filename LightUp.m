classdef LightUp
    %LIGHTUP 逻辑游戏LightUp求解工程
    %   此处显示详细说明
    
    properties(Constant)
        % 所有数据禁止修改
        
        dirU = 1        % 方向常数
        dirD = 3        % 方向常数
        dirL = 2        % 方向常数
        dirR = 4        % 方向常数
        
        utypeBlc    = -1
        utypeUnn    = -2
        utypeLamp   = -3
        utypeLit    = -4
        utypeNLmp   = -5
        
    end
    
    properties
        height      % 高度
        width       % 宽度
        mat         % 题面矩阵
        
        indS4       % 四个方向下标偏移值
        indA4       % 四个顶角下标偏移值
        
        rowPairs    % 连续空行,cell(height,1),内部(pairsNum * 2)
        colPairs    % 连续空列,cell(width,1),内部(pairsNum * 2)
        
        blackInd    % 数字黑格下标
        blackDig    % 黑格数字
        
    end
    
    methods
        function obj = LightUp(tokStrArg)
            %LIGHTUP 构造此类的实例
            %   Input
            %       tokStrArg token字符串
            
            % 解析字符串
            [obj.mat, obj.height, obj.width, obj.blackInd] = ...
                luTokenResolve(tokStrArg);
            
            % 四个方向下标偏移值
            obj.indS4 = zeros(1,4);
            obj.indS4(obj.dirU) = -1;
            obj.indS4(obj.dirD) = 1;
            obj.indS4(obj.dirL) = -obj.height;
            obj.indS4(obj.dirR) = obj.height;
            obj.indA4 = reshape([-obj.height obj.height] + [-1;1], [1 4]);
            
            % 黑格数字
            obj.blackDig = obj.mat(obj.blackInd);
            
            % 生成连续空行/列
            obj.rowPairs = cell(obj.height, 1);
            obj.colPairs = cell(obj.width, 1);
            obj = obj.initRCPairs();

        end
        
        function obj = Genesis(obj)
            %GENESIS 求解工程
            
            % 每一个数字黑格处理
            for ind = 1:length(obj.blackInd)
                obj = obj.checkBlack(ind);
            end
            
            % 每一个行列条带处理
            
        end
        
        function obj = initRCPairs(obj)
            %INITRCPAIRS 初始化连续空行/列
            for ii = 1:obj.width
                cc = diff(obj.mat(:,ii) >= obj.utypeBlc);
                obj.colPairs{ii} = cat(2, find(cc == -1) + 1,find(cc == 1));
            end
            for jj = 1:obj.height
                cc = transpose(diff(obj.mat(jj,:) >= obj.utypeBlc));
                obj.rowPairs{jj} = cat(2, find(cc == -1) + 1,find(cc == 1));
            end
            
        end
        
        function obj = checkBlack(obj, ind)
            %CHECKBLACK 检测数字黑格
            % Input
            %       ind     : 数字黑格在blackInd中下标
            
            % mat中位置下标
            matInd = obj.blackInd(ind);
            
            % 数字
            digit = obj.blackDig(ind);
            
            % 周边信息
            matS = obj.matSGet(matInd);
            
            % 已有灯位置 - 布尔型
            b2 = (matS == obj.utypeLamp);
            % 残留可填位置
            b3 = (matS == obj.utypeUnn);
            % 可填位置 - 布尔型
            b1 = b2 | b3;
            if(nnz(b1) == digit)
                % 周边可填位置等于数字 -> 可填位置放置灯
                obj = obj.addLamp(matInd + obj.indS4(b1));
            elseif(nnz(b2) == digit)
                % 周围灯数等于数字 -> 剩余位置设置不可放属性
                obj.mat(matInd + obj.indS4(~b2)) = obj.utypeNLmp;
            elseif(nnz(b3) - digit + nnz(b2) == 1)
                % 残留可填位置数 - 残留灯数 = 1
                % 四个顶角判断
                switch(nnz(b3))
                    case{4}
                        obj.mat(matInd + obj.indA4) = obj.utypeNLmp;
                    case{3}
                        % 残留位置中空元素
                        indDir = find(~b3,1,'first');
                        % 转换为待写入两个方向
                        indDir = mod(indDir + [0 1],4) + 1;
                        obj.mat(matInd + obj.indA4(indDir)) = obj.utypeNLmp;
                    case{2}
                        % 不能为水平型，即不能为(1,3)或(2,4)
                        if(any(b3 & b3([4 1 2 3])))
                            % 待写入一个方向
                            indDir = find(b3,1,'last') - 1;
                            obj.mat(matInd + obj.indA4(indDir)) = obj.utypeNLmp;
                        end
                end
            end
            
        end
        
        function obj = addLamp(obj, lampIndA)
            %ADDLAMP 添加灯
            % Input:
            %       lampIndA    : 灯在矩阵中下标向量
            for lampInd = lampIndA
                if(obj.mat(lampInd) == obj.utypeLamp)
                    continue
                end
                % 从pairs中读取连续行列
                [row, col] = ind2sub([obj.height obj.width], lampInd);
                % 连续列设置Lit属性
                indT = find(obj.colPairs{col}(:,2) >= row, 1,'first');
                obj.mat(obj.colPairs{col}(indT,1):obj.colPairs{col}(indT,2), col) = obj.utypeLit;
                % 连续行设置Lit属性
                indT = find(obj.rowPairs{row}(:,2) >= col, 1,'first');
                obj.mat(row, obj.rowPairs{row}(indT,1):obj.rowPairs{row}(indT,2)) = obj.utypeLit;
                % 自己设置为Lamp属性
                obj.mat(lampInd) = obj.utypeLamp;
            end
        end
        
        function matS = matSGet(obj, matInd)
            %MATSGET 返回四周状态
            
            % 获取状态
            matS = obj.mat(matInd + obj.indS4);
        end
        
        function Display(obj)
            % 关闭已有图窗
            try
                close('LightUp')
            catch ME
                if(~strcmp(ME.identifier, 'MATLAB:close:WindowNotFound'))
                    rethrow(ME)
                end
            end
            % 新建图窗
            h = figure('Name', 'LightUp');
            hold on
            
            % 绘制黑格
            spy(obj.mat >= obj.utypeBlc, 'sk');
            % 绘制灯
            spy(obj.mat == obj.utypeLamp, 30, '.r');
            % 绘制点亮区域
            spy(obj.mat == obj.utypeLit, 30, '.y');
            
            % 绘制不可填充
            spy(obj.mat == obj.utypeNLmp,'xm');
            
            % 绘制网格
            for ii = 1:obj.height - 1
                yline(ii + 0.5,'Color',[0.1 0.1 0.1]);
            end
            for ii = 1:obj.width - 1
                xline(ii + 0.5,'Color',[0.1 0.1 0.1]);
            end
            
            % 窗口大小
            axis([1.5 obj.height-0.5 1.5 obj.height-0.5]);
            
            % 图例
            legend('黑格','灯','点亮区域','不可填充',...
                'Location','northeastoutside');
            
            % 标签
            xlabel('');
        end
    end
end

