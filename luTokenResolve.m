function [mat, height, width, blackInd] = luTokenResolve(tokStr)
%LUTOKENRESOLVE LightUp字符串解析函数
%   Input
%       tokStr
%   Output
%       height      : 高度
%       width       : 宽度
%       mat         : 题面矩阵
%       blackInd    : 数字黑格下标

% Example
% tokStr = 'a1h0b2h2a3aBh2bBh1a';
% height = 7
% width = 7
% mat = 
%     -2     1    -2    -2    -2    -2    -2
%     -2    -2    -2     0    -2    -2     2
%     -2    -2    -2    -2    -2    -2    -2
%     -2     2    -2     3    -2    -1    -2
%     -2    -2    -2    -2    -2    -2    -2
%      2    -2    -2    -1    -2    -2    -2
%     -2    -2    -2    -2    -2     1    -2

% blackInd = 
%      8    23    44    11    25     6 

utypeBlc    = -1;
utypeUnn    = -2;

% 以黑格拆分
[brick, nonBrickInt] = regexp(tokStr,'[0-4B]','match','split');

% 黑格数字
brickDig = str2double(brick);
brickDig(isnan(brickDig)) = utypeBlc;

% 计算黑格间间隔
funcT = @(x) sum(abs(x) - 96);
intv = cellfun(funcT, nonBrickInt);

% 计算黑格下标
blackInd = cumsum(intv) + (1:length(intv));

% 计算行列数
[height, width] = sizeDefine(blackInd(end) - 1);

% 建立题面矩阵
mat = utypeUnn * ones([width height]);  % 后续转置恢复正常
mat(blackInd(1:end-1)) = brickDig;
mat = transpose(mat);

if(nargout > 3)
    % 只保留数字黑格
    blackInd = blackInd(brickDig ~= utypeBlc);
    
    % 重新转置
    [row,col] = ind2sub([width height],blackInd);
    blackInd = sub2ind([height width], col, row);
end

end

%%
function [height, width] = sizeDefine(matNumel)
%SIZEDEFINE 自定义行列数
switch(matNumel)
    case{49, 100, 196, 625, 900}
        height = sqrt(matNumel);
        width = sqrt(matNumel);
    case{1200}
        height = 40;
        width = 30;
    case{2000}
        height = 50;
        width = 40;
    otherwise
        error('Error:无法确定行列数')
end

end
