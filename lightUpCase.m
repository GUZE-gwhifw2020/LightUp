%% Birth Certificate
% ===================================== %
% DATE OF BIRTH:    2020.12.14
% NAME OF FILE:     lightUpCase
% FILE OF PATH:     /LightUp
% FUNC:
%   LightUp类实例
% ===================================== %

%%
% strToken = input('    输入Token:','s');
strToken = input('== ', 's');
if(isempty(strToken))
    strToken = 'a1h0b2h2a3aBh2bBh1a';
end

X = LightUp(strToken);

%%
X = X.Genesis();

X.Display();