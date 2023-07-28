clc; clear all;close all;
%%  参数预设
N = 1000; %定义N为采集的帧数
V = 5;    %定义V为机器人移动速率mm/s
t = 1000/31.3; %定义t为帧间隔时间s
%% 读入-二进制转十进制坐标
fileID0 = fopen('1-1.dat');
Bin = fread(fileID0,"uint16");

for i=1:N
    for j=1:960
        Z(i,j)=Bin(960*(i-1)+j);
    end
end

%% 像素绘图
for i=1:N
    Y(i)=V*t;
end

% figure(1);clf(1);
% for i=1:1000
%     for j=1:960
%         plot3(j,i,Z(i,j),'.b');
%         hold on;
%     end
% end

%% 导出像素点
writematrix(Z,'z.txt')

system('Point2real.exe');

%fileID1 = fopen('xr.txt');
XR = importdata('xr.txt',',');

%fileID2 = fopen('zr.txt');
ZR = importdata('zr.txt',',');


figure(2);clf(2);
plot(XR(500,:),ZR(500,:));

