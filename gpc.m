% mygpc.m
% 测试GPC函数
function r=gpc(img)
[m,n] =size(img);
A=1.5:2:255.5;
B=0.5:2:254.5;
img = img';
% 初始化数据
n0=0;n1=0;
vec=[];
r=0;
for i=1:1:m*n-1
    a=img(i);b=img(i+1);
    x=min(a,b);y=max(a,b);
    if x~=y
        x=double(x);
        y=double(y);
        vec=x:0.5:y;% 生成向量
        res0=sum(ismember(vec,A));%求穿过多少位平面
        res1=sum(ismember(vec,B));
        n0=n0+res0;n1=n1+res1; % 计数  
    end
end
r=n1/n0;
end