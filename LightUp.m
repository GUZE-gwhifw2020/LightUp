classdef LightUp
    %LIGHTUP 逻辑游戏LightUp求解工程
    %   此处显示详细说明
    
    properties(Constant)
        dirU = 1        % 方向常数
        dirD = 2        % 方向常数
        dirL = 3        % 方向常数
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
        
        rowPairs    % 连续空行,cell(height,1),内部(pairsNum * 2)
        colPairs    % 连续空列,cell(width,1),内部(pairsNum * 2)
  
        blackInd    % 数字黑格下标
        blackDig    % 黑格数字
        
        addLampInd  % 待加入灯下标(行向量)
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
            obj.indS4 = [-1 1 -obj.height obj.height];
           
            % 黑格数字
            obj.blackDig = obj.mat(obj.blackInd);

            % 生成连续空行/列
            obj.rowPairs = cell(obj.height, 1);
            obj.colPairs = cell(obj.width, 1);
            obj = obj.initRCPairs();
            
            % 待加入灯下标
            obj.addLampInd = [];
            
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
            % 可填位置 - 布尔型
            b1 = b2 | (matS == obj.utypeUnn);
            if(nnz(b1) == digit)
                % 周边可填位置等于数字 -> 可填位置放置灯
                obj.addLampInd = cat(2, obj.addLampInd, matInd + obj.indS4(b1));
            elseif(nnz(b2) == digit)
                % 周围灯数等于数字 -> 剩余位置设置不可放属性
                obj.mat(matInd + obj.indS4(~b2)) = obj.utypeNLmp;
            end

        end
        
        function obj = addLamp(obj)
            %ADDLAMP 添加灯
            
            for lampInd = obj.addLampInd
                if(obj.mat(lampInd) == obj.utypeLamp)
                    continue
                end
                % 从pairs中读取连续行列
                [row, col] = ind2sub([obj.height obj.width], lampInd);
                % 连续列设置Lit属性
                indT = find(obj.colPairs{col}(:,2) >= row, 1,'first');
                obj.mat(obj.colPairs{col}(indT,1):obj.colPairs{col}(indT,2), col) = obj.utypeLit;
                % 连续行设置Lit属性
                indT = find(obj.rowPairs{row}(:,1) >= col, 1,'first');
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
    end
end

