clc
clear all
close all

[name,path]=uigetfile('.\*.*');  % 选择文件
I=imread([path,name]); 

bili=0.5; %背景所占比例
%% 

figure(1)
subplot(221)
imshow(I)

%% 高斯滤波
W = fspecial('gaussian',[5,5],1); 
G = imfilter(I, W, 'replicate');
subplot(222)
imshow(G)

%% 直方图
subplot(223)
[counts,x] = imhist(G);
stem(x,counts,'Marker', 'none')
%% 阈值化

[max_I,index]=max(counts);
[m,n]=size(I);
i=index;
he=0;
while i>0
    he=he+counts(i);
    if counts(i)<counts(i-1) & he/m/n>bili
        index0=i;
        break
    end
    i=i-1;
end
z=counts(index0);
index00=index0;
for i=index0:256
    if counts(i)<3*z 
        index00=index00+1;
        if index00-index0>10
            break
        end
    end
end
thre=(index00)/255;
% thre=graythresh(I);%获取otsu算得的阈值
bw=1-im2bw(G,thre);
% bw = 1-imbinarize(I,thre);%二值化
subplot(224)
imshow(bw);
title('阈值化');

%% 数值水平统计
figure(2)
ycount=[];
xcount=[];
for i=1:size(bw,1)
    ycount(i,1)=sum(bw(i,:));
end
for j=1:size(bw,2)
    xcount(j,1)=sum(bw(:,j));
end


subplot(221)
stem(ycount,'Marker', 'none');
subplot(222)
stem(xcount,'Marker', 'none');

% 去除边缘直尺左边还是右边
if sum(xcount(1:270)>5000 & xcount(1:270) <6000)>255
    flag=1;
elseif sum(xcount(end-270+1:end)>5000 & xcount(end-270+1:end) <6000)>255
    flag=-1;
end
if flag==1
    for i=1:400
        if xcount(i)<6000/10 & i>250
            break 
        end
    end
    index1=i+20;
    bw(:,1:index1)=0;
else
    for i=length(xcount):flag:length(xcount)-399
        if xcount(i)<6000/10 & i<length(xcount)-250
            break 
        end
    end
    index2=i-20;
    bw(:,index2:end)=0;
end
bw(150,2:end-1)=0;
bw(end-150,2:end-1)=0;
bw(2:end-1,150)=0;
bw(2:end-1,end-150)=0;
bw = imclearborder(bw,8); %

subplot(223)
bw1=bw;
imshow(bw1)

se=strel('disk',6);
I2=imdilate(bw1, se);             %进行膨胀处理

subplot(224)
imshow(I2)

%%
figure(3)
subplot(221)
I3=imerode(I2, se);                %进行腐蚀处理
imshow(I3)


se2=strel('disk',20);
subplot(222)
I4=imerode(I3, se2);                %进行腐蚀处理
imshow(I4)


I5 = imfill(I4,'holes');  % 填充孔洞
I6 = bwareaopen(I5,8000);

I7=imdilate(I6, se2);             %进行膨胀处理

subplot(223)
imshow(I7)

subplot(224)
e=edge(I7,'canny');
imshow(e)

%% 显示结果

figure(4)
subplot(121)
imshow(I)

subplot(122)
I8 = imresize(I7,[1000 NaN]);
I8 = imfill(I8,'holes');  % 填充孔洞
e2=edge(I8,'canny');
e2_xianshi=imdilate(e2,[1 1 1;1 1 1;1 1 1]);             %进行膨胀处理
e3=1-e2_xianshi;
imshow(e3)

imwrite(e3,'边缘.jpg')

