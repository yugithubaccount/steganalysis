function p=chi(x)
% x 是一幅图像
% 检测卡方分析的函数
n=sum(hist(x,[0:255]),2);% 矩阵按行求和,hist求频数,得到的是一个列向量
h2i=n([1:2:255]);% 取奇数
h2is=(h2i+n([2:2:256]))/2;
filter=(h2is~=0);   % 过滤器
k=sum(filter);      % 统计不是0的
idx=zeros(1,k);     % 生成数组
for i=1:128
    if filter(i)==1
        idx(sum(filter(1:i)))=i;% 计算当前有多少1
    end
end
r=sum(((h2i(idx)-h2is(idx)).^2)./(h2is(idx)));
p=1-chi2cdf(r,k-1);% 计算概率
end