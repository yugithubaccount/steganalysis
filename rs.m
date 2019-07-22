function r = rs(img)
Fig=img;
[x,y] = size(Fig);
Type1 = 2; % BlockSize
Type2 = 1; % 1:Row first 2:Col first 3:ZigZag
%进行处理
[Rm,Sm,Um,R1m,S1m,U1m] = RSU(Fig,x*y,Type1,Type2);
ComFig = bitxor(double(Fig),ones(x,y));% 进行一次翻转
[CRm,CSm,CUm,CR1m,CS1m,CU1m] = RSU(ComFig,x*y,Type1,Type2);
d0 = Rm - Sm;
d1 = CRm - CSm;
d10 = R1m - S1m;
d11 = CR1m - CS1m;
a = 2*(d0 + d1);
b = d10 - d11 - d1 - 3*d0;
c = d0 - d10;
root = [a,b,c];
solutions = roots(root);
% 输出结果
if size(solutions) == 1
    r = solutions;
    return
end
if abs(solutions(1)) > abs(solutions(2))
	   r=solutions(2)/(solutions(2)-1/2);
       r = real(r);
	else
	   r=solutions(1)/(solutions(1)-1/2);
       r = real(r);
end

end
%% 暂时不用这函数

function [R,S,U,R1,S1,U1] = RSU(A,bufsize,Type1,Type2)
R = 0;
S = 0;
U = 0;
R1 = 0;
S1 = 0;
U1 = 0;
%%
% override A 2*2
if Type1 == 2 %类型2
    BlockSize = 4;
    BlockCol = 2;
    BlockRow = 2;
    [x,y] = size(A);
    TmpA = zeros(bufsize/BlockSize,BlockRow,BlockCol);
    % Row first
    BlockNum = 1;
    for i = 1:x/BlockRow
        for j = 1:y/BlockCol
            TmpA(BlockNum,1,1) = A(BlockRow*(i-1)+1,BlockCol*(j-1)+1);
            TmpA(BlockNum,1,2) = A(BlockRow*(i-1)+1,BlockCol*(j-1)+2);
            TmpA(BlockNum,2,1) = A(BlockRow*(i-1)+2,BlockCol*(j-1)+1);
            TmpA(BlockNum,2,2) = A(BlockRow*(i-1)+2,BlockCol*(j-1)+2);
            BlockNum = BlockNum + 1;
        end
    end
end
%%
% override A 3*3
if Type1 == 3
    BlockSize = 9;
    BlockCol = 3;
    BlockRow = 3;
    [x,y] = size(A);
    TmpA = zeros(bufsize/BlockSize,BlockRow,BlockCol);
    % Row first
    BlockNum = 1;
    for i = 1:x/BlockRow
        for j = 1:y/BlockCol
            for k = 1:BlockRow
                for l = 1:BlockCol
                    TmpA(BlockNum,k,l) = A(BlockRow*(i-1)+k,BlockCol*(j-1)+l);
                end
            end
            BlockNum = BlockNum + 1;
        end
    end
end

%%
% override A 4*4
if Type1 == 4
    BlockSize = 16;
    BlockCol = 4;
    BlockRow = 4;
    [x,y] = size(A);
    TmpA = zeros(bufsize/BlockSize,BlockRow,BlockCol);
    % Row first
    BlockNum = 1;
    for i = 1:x/BlockRow
        for j = 1:y/BlockCol
            for k = 1:BlockRow
                for l = 1:BlockCol
                    TmpA(BlockNum,k,l) = A(BlockRow*(i-1)+k,BlockCol*(j-1)+l);
                end
            end
            BlockNum = BlockNum + 1;
        end
    end
end
%%
for n = 1: bufsize/BlockSize
    x = zeros(1,BlockSize);
    G = zeros(1,BlockSize);
    H = zeros(1,BlockSize);
%    for m = 1: 4
%        x(m) = A(4*(n-1) + m);
%    end
    m = 1;
    if Type2 == 1
        % 1: Row first  
        for i = 1:BlockRow
            for j = 1:BlockCol
                x(m) = TmpA(n,i,j);
                m = m + 1;
            end
        end
    elseif Type2 == 2
        % 2: Col first
        for j = 1:BlockCol
            for i = 1:BlockRow
                x(m) = TmpA(n,i,j);
                m = m + 1;
            end
        end
    else
        % 3: ZigZag
        if Type1 == 2
            x(1) = TmpA(n,1,1);
            x(2) = TmpA(n,1,2);
            x(3) = TmpA(n,2,1);
            x(4) = TmpA(n,2,2);
        else
            x(1) = TmpA(n,1,1);
            x(2) = TmpA(n,1,2);
            x(3) = TmpA(n,2,1);
            x(4) = TmpA(n,3,1);
            x(5) = TmpA(n,2,2);
            x(6) = TmpA(n,1,3);
            x(7) = TmpA(n,2,3);
            x(8) = TmpA(n,3,2);
            x(9) = TmpA(n,3,3);
        end
    end
    fG = f(x);
    
    % 2*2 : M(0,1,1,0)
    % 3*3 : M(0,1,0,1,1,1,0,1,0)
    % 4*4 : M(0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0)
    if Type1 == 2
        M = [0,1,1,0];
    elseif Type1 == 3
        M = [0,1,0,1,1,1,0,1,0];
    else
        M = [0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0];
    end
    
    for i = 1:BlockSize
        if M(i) == 0
            G(i) = F0(x(i));
        else
            G(i) = F1(x(i));
        end
    end
    FsG = f(G);
    
    if FsG>fG 
        R = R + 1;
    elseif FsG < fG 
        S = S + 1;
    else 
        U = U + 1;
    end
    
    % 2*2 : M(0,-1,-1,0)
    % 3*3 : M(0,-1,0,-1,-1,-1,0,-1,0)
    % 4*4 : M(0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0)
    if Type1 == 2
        M = [0,-1,-1,0];
    elseif Type1 == 3
        M = [0,-1,0,-1,-1,-1,0,-1,0];
    else
        M = [0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0];
    end
    
    for i = 1:BlockSize
        if M(i) == 0
            H(i) = F0(x(i));
        else
            H(i) = Fne(x(i));
        end
    end
    FsH = f(H);
    
    if FsH>fG 
        R1 = R1 + 1;
    elseif FsH < fG 
        S1 = S1 + 1;
    else 
        U1 = U1 + 1;
    end
end
end

function sum = f(x)
sum = 0;
for n = 1:3
    sum = sum + abs(x(n+1)-x(n));
end
end

function y = F0(x)
y = x;
end

function y = F1(x)
if mod(x,2) == 0
    y = x + 1;
else
    y = x - 1;
end
end


function y = Fne(x)
    if mod(x,2) == 0
        y = x - 1;
    else
        y = x + 1;
    end
end
