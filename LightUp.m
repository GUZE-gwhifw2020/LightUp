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
        
        rowPairs    % 连续空行
        colPairs    % 连续空列
  
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
            
            % 黑格数字
            obj.blackDig = obj.mat(obj.blackInd);

            
        end
        
        function obj = Genesis(obj)
            %GENESIS 求解工程
            
            % 每一个数字黑格处理
            
            % 每一个行列条带处理
        end
    end
end

