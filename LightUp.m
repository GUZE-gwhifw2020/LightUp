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
        
        rowPairs    % 连续空行，大小matrix(3, pairsNum)
        colPairs    % 连续空列，大小matrix(3, pairsNum)
        
        rowPairInd  % 非黑格空行坐标，大小matrix(height, width)
        colPairInd  % 非黑格空行坐标，大小matrix(height, width)
        
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
            
            % 生成连续空行/列坐标
            obj = obj.initRCPairs();

        end
        
        function obj = Genesis(obj)
            %GENESIS 求解工程
            
            for iter = 1:7
                % 每一个数字黑格处理
                for ind = 1:length(obj.blackInd)
                    obj = obj.checkBlack(ind);
                end
                
                % 每一个行列条带处理
                for ii = 1:size(obj.rowPairs, 2)
                    obj = obj.checkColPairs(ii);
                end
                for ii = 1:size(obj.colPairs, 2)
                    obj = obj.checkRowPairs(ii);
                end
            end
        end
        
        function obj = initRCPairs(obj)
            %INITRCPAIRS 初始化连续空行/列，和下标矩阵
            
            % 未确定位置矩阵
            matUnn = obj.mat == obj.utypeUnn;
            % 辅助矩阵
            matTemp = false(size(obj.mat));
            
            % 逐列判断
            for ii = 1:obj.width
                % 利用1 0 0 1 0差分后确定间隔位置
                cc = transpose(diff(matUnn(:, ii)));
                obj.colPairs = cat(2, obj.colPairs, cat(1, find(cc == 1) + 1,find(cc == -1), repmat(ii, [1, nnz(cc == 1)])));
                matTemp(find(cc == 1) + 1, ii) = true;
            end
            % 连续空列下标赋值
            obj.colPairInd = reshape(cumsum(matTemp(:)), size(obj.mat));
            obj.colPairInd(~matUnn) = 0;
            
            % 辅助矩阵
            matTemp = false(size(obj.mat'));
            % 逐行判断
            for jj = 1:obj.height
                cc = diff(matUnn(jj,:));
                obj.rowPairs = cat(2, obj.rowPairs, cat(1, find(cc == 1) + 1,find(cc == -1), repmat(jj, [1, nnz(cc == 1)])));
                matTemp(find(cc == 1) + 1, jj) = true;
            end
            % 连续空行下标赋值
            obj.rowPairInd = reshape(cumsum(matTemp(:)), size(obj.mat'))';
            obj.rowPairInd(~matUnn) = 0;
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
            
            % 
            indBiasA = [];
            
            if(nnz(b1) == digit)
                % 周边可填位置等于数字 -> 可填位置放置灯
                obj = obj.addLamp(matInd + obj.indS4(b1));
            elseif(nnz(b2) == digit)
                % 周围灯数等于数字 -> 剩余位置设置不可放属性
                % obj.mat(matInd + obj.indS4(~b2)) = obj.utypeNLmp;
                indBiasA = obj.indS4(~b2);
            elseif(nnz(b3) - digit + nnz(b2) == 1)
                % 残留可填位置数 - 残留灯数 = 1
                % 四个顶角判断
                switch(nnz(b3))
                    case{4}
                        % obj.mat(matInd + obj.indA4) = obj.utypeNLmp;
                        indBiasA = obj.indA4;
                    case{3}
                        % 残留位置中空元素
                        indDir = find(~b3,1,'first');
                        % 转换为待写入两个方向
                        indDir = mod(indDir + [0 1],4) + 1;
                        % obj.mat(matInd + obj.indA4(indDir)) = obj.utypeNLmp;
                        indBiasA = obj.indA4(indDir);
                    case{2}
                        % 不能为水平型，即不能为(1,3)或(2,4)
                        if(any(b3 & b3([4 1 2 3])))
                            % 待写入一个方向
                            indDir = find(b3,1,'last') - 1;
                            % obj.mat(matInd + obj.indA4(indDir)) = obj.utypeNLmp;
                            indBiasA = obj.indA4(indDir);
                        end
                end
            end
            
            indBiasA = matInd + indBiasA;
            indBiasA(obj.mat(indBiasA) ~= obj.utypeUnn) = [];
            
            obj.mat(indBiasA) = obj.utypeNLmp;
            
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
                % 连续列设置Lit属性，从连续空列中查询到列范围
                span = obj.colPairs(:, obj.colPairInd(lampInd));
                obj.mat(colon(span(1), span(2)), col) = obj.utypeLit;
                
                % 连续行设置Lit属性，从连续空行中查询到行范围
                span = obj.rowPairs(:, obj.rowPairInd(lampInd));
                obj.mat(row, colon(span(1), span(2))) = obj.utypeLit;
                
                % 自己设置为Lamp属性
                obj.mat(lampInd) = obj.utypeLamp;
            end
        end
        
        function matS = matSGet(obj, matInd)
            %MATSGET 返回四周状态
            
            % 获取状态
            matS = obj.mat(matInd + obj.indS4);
        end
        
        function obj = checkColPairs(obj, ind)
            %CHECKCOLPAIRS 确定连续空列的第ind组是否更新
            
            % Rev: 原先认为只要连续列中只有一个Unn就应该是Lamp
            % 实际判断准则还需同时考虑连续行
            % 1. 在行列中均为唯一的Unn
            % 2. 列中为唯一的Unn，且该列中存在Cross不可能在行中点亮
            %    也即该行中不存在Unn
            
            span = obj.colPairs(1:2, ind);
            colInd = obj.colPairs(3, ind);
            
            % 寻找该空列中Unn类型个数
            rowInd = find(obj.mat(span(1):span(2),colInd) == obj.utypeUnn);
            if(length(rowInd) == 1)
                % 转换为实际下标
                rowInd = rowInd - 1 + span(1);
                
                % 1. 对应连续空行中Unn个数是否为1
                span = obj.rowPairs(:, obj.rowPairInd(rowInd, colInd));
                J1 = (nnz(obj.mat(rowInd, span(1):span(2)) == obj.utypeUnn) == 1);
                
                % 2. 寻找该空列的Cross所在的行中是否无Unn
                J2 = false;
                rowIndTA = find(obj.mat(span(1):span(2), colInd) == obj.utypeNLmp) - 1 + span(1);
                for iter = 1:length(rowIndTA)
                    rowIndT = rowIndTA(iter);
                    spanT = obj.colPairs(1:2, obj.rowPairInd(rowIndT, colInd));
                    if(all(obj.mat(rowIndT, spanT(1):spanT(2)) ~= obj.utypeUnn))
                        J2 = true;
                        break;
                    end
                end
                if(J1 || J2)
                    obj = obj.addLamp(sub2ind([obj.height obj.width], ...
                        rowInd, colInd));
                end
            end
        end
        
        function obj = checkRowPairs(obj, ind)
            %CHECKROWPAIRS 确定连续空行的第ind组是否更新

            span = obj.rowPairs(1:2, ind);
            rowInd = obj.rowPairs(3, ind);
            
            % 寻找空行中Unn个数
            colInd = find(obj.mat(rowInd, span(1):span(2)) == obj.utypeUnn);
            if(length(colInd) == 1)
                % 转换为实际下标
                colInd = colInd - 1 + span(1);
                
                % 1. 对应列中Unn个数是否为1
                span = obj.colPairs(:, obj.colPairInd(rowInd, colInd));
                J1 = (nnz(obj.mat(span(1):span(2), colInd) == obj.utypeUnn) == 1);
                
                % 2. 寻找该空行的Cross所在列中是否无Unn
                J2 = false;
                colIndTA = find(obj.mat(rowInd, span(1):span(2)) == obj.utypeNLmp) - 1 + span(1);
                for iter = 1:length(colIndTA)
                    colIndT = colIndTA(iter);
                    spanT = obj.rowPairs(1:2, obj.colPairInd(rowInd, colIndT));
                    if(all(obj.mat(spanT(1):spanT(2), colIndT) ~= obj.utypeUnn))
                        J2 = true;
                    end
                end
                
                if(J1 || J2)
                    obj = obj.addLamp(sub2ind([obj.height obj.width], ...
                        rowInd, colInd));
                end
                
            end
            
            
        end
        
        function Display(obj)
            % 新建图窗
            h = figure('Name', 'LightUp', 'NumberTitle', 'off');
            clf
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

