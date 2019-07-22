function r=new(img)
% r 比率
% img 待检测的图像
[m,n] =size(img);
I=img;
stg=I';% stg 表示隐写图像
s12_=0;s2_=0;
r = 0;
for i=1:1:m*n-1
    if ( mod(stg(i),2)==1 && mod(stg(i+1),2)==0 && stg(i)-stg(i+1) >1) % 计算s12_
        s12_ = s12_+1;
    end
    if ( mod(stg(i),2)==1 && mod(stg(i+1),2)==0 && stg(i)<stg(i+1) ) % 计算s2_
        s2_ = s2_+1;
    end
end
s12_ = s12_/(m*n-1);
s2_ = s2_/(m*n-1);
s2 =0.125;
r = 2*(s2-s2_)/(2*s2-s12_-s2_);
end