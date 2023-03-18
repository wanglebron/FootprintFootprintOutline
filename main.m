clc
clear all
close all

[name,path]=uigetfile('.\*.*');  % ѡ���ļ�
I=imread([path,name]); 

bili=0.5; %������ռ����
%% 

figure(1)
subplot(221)
imshow(I)

%% ��˹�˲�
W = fspecial('gaussian',[5,5],1); 
G = imfilter(I, W, 'replicate');
subplot(222)
imshow(G)

%% ֱ��ͼ
subplot(223)
[counts,x] = imhist(G);
stem(x,counts,'Marker', 'none')
%% ��ֵ��

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
% thre=graythresh(I);%��ȡotsu��õ���ֵ
bw=1-im2bw(G,thre);
% bw = 1-imbinarize(I,thre);%��ֵ��
subplot(224)
imshow(bw);
title('��ֵ��');

%% ��ֵˮƽͳ��
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

% ȥ����Եֱ����߻����ұ�
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
I2=imdilate(bw1, se);             %�������ʹ���

subplot(224)
imshow(I2)

%%
figure(3)
subplot(221)
I3=imerode(I2, se);                %���и�ʴ����
imshow(I3)


se2=strel('disk',20);
subplot(222)
I4=imerode(I3, se2);                %���и�ʴ����
imshow(I4)


I5 = imfill(I4,'holes');  % ���׶�
I6 = bwareaopen(I5,8000);

I7=imdilate(I6, se2);             %�������ʹ���

subplot(223)
imshow(I7)

subplot(224)
e=edge(I7,'canny');
imshow(e)

%% ��ʾ���

figure(4)
subplot(121)
imshow(I)

subplot(122)
I8 = imresize(I7,[1000 NaN]);
I8 = imfill(I8,'holes');  % ���׶�
e2=edge(I8,'canny');
e2_xianshi=imdilate(e2,[1 1 1;1 1 1;1 1 1]);             %�������ʹ���
e3=1-e2_xianshi;
imshow(e3)

imwrite(e3,'��Ե.jpg')

