clc
clear all;
close all;
path = './dataset/pre/';
n = 128;
m = n;
rate_chi = zeros(11,200);% 加快速度
rate_infoguess = zeros(11,200);% 加快速度
rate_gpc = zeros(11,200);% 加快速度
rate_new = zeros(11,200);% 加快速度
rate_rs = zeros(11,200);% 加快速度
for k=11:1:11
   for i = 1:1:200
      str1 = [path,num2str((k-1)*10),'/',num2str(i),'.bmp']
      I = imread(str1);
      rate_chi(k,i) =chi(I);
           r0 = gpc(I);rng(88888-i); msg=randsrc(m,n,[0 1;0.5 0.5]);I2=bitset(I,1,msg);r1=gpc(I2);b=1;c = r1-b;alpha = (r0-b)/c;
      rate_gpc(k,i) =alpha;
      rate_infoguess(k,i) =infoguess(I);
      rate_new(k,i) =new(I);
      rate_rs(k,i) =rs(I);
   end
end
save pre
