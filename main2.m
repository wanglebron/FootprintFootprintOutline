

clc
clear all
close all

Path = '.\45\';                   % �������ݴ�ŵ��ļ���·��
File = dir(fullfile(Path,'*.jpg'));  % ��ʾ�ļ��������з��Ϻ�׺��Ϊ.txt�ļ���������Ϣ
FileNames = {File.name}'; 

for ii=1:size(FileNames,1)

I=imread([Path,FileNames{ii}]); 

bili=0.5; %������ռ����
%% 


%% ��˹�˲�
W = fspecial('gaussian',[5,5],1); 
G = imfilter(I, W, 'replicate');


%% ֱ��ͼ

[counts,x] = imhist(G);
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



%% ��ֵˮƽͳ��
ycount=[];
xcount=[];
for i=1:size(bw,1)
    ycount(i,1)=sum(bw(i,:));
end
for j=1:size(bw,2)
    xcount(j,1)=sum(bw(:,j));
end



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


bw1=bw;


se=strel('disk',6);
I2=imdilate(bw1, se);             %�������ʹ���



%%

I3=imerode(I2, se);                %���и�ʴ����



se2=strel('disk',20);

I4=imerode(I3, se2);                %���и�ʴ����



I5 = imfill(I4,'holes');  % ���׶�
I6 = bwareaopen(I5,8000);

I7=imdilate(I6, se2);             %�������ʹ���



e=edge(I7,'canny');


%% ��ʾ���






I8 = imresize(I7,[1000 NaN]);
I8 = imfill(I8,'holes');  % ���׶�
e2=edge(I8,'canny');
e2_xianshi=imdilate(e2,[1 1 1;1 1 1;1 1 1]);             %�������ʹ���
e3=1-e2_xianshi;


imwrite(e3,['����\',num2str(ii),'.jpg'])
end
