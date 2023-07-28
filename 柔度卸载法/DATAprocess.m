clc; clear all;close all;
N=3; %精度规定至小数点后N位
%%  数据读入
data = xlsread ('datalxx');
size = size(data, 1);
d = round(data(1:size,1),N);   %data为加载开始点与终止点数据。
orid=data(1:size,1);
p = data(1:size,2);
figure(1);clf(1);
plot(d,p,'LineWidth',2);
hold on;
%% 粗略找点
  nou = input("请输入卸载次数:\n");
  stp0 = input("请输入初始位移步长:\n");
  stp  = input("请输入迭代位移步长:\n");
  Status=[];
  st=[];
  ed=[];
 
  % typedef class unloadPoint
  % {
  %   int status;
  %   double x,y;
  %   int No;
  % };
  % unloadPoint.status

  for i=1:nou
      Status(i)=-1;
  end
  
  for i=1:nou
    STdx=stp0+(i-1)*stp;
    EDdx=stp0+(i-2)*stp;
      for j=1:size-1
          %disp(num2str((d(j)-STdx)<10^(-5*N)));
          if (abs(d(j)-STdx)<10^(-1*N) && Status(i) == -1)
              st(i) = j;
              Status(i) = Status(i)+1;
          elseif (abs(d(j)-EDdx)<10^(-5*N) && Status(i) == 0 )
              ed(i) = j;
              Status(i) = Status(i)+1;
          end
          % 由于matlab的数据类型控制远没有C++来的便捷，难以避免地
          % 出现了浮点数误差问题，理论上d(j)-STdx=0,实际采用断言
          % 绝对值小于一个小值的方式解决,而非以下方法。之后优选使用C++编程。
          % if (d(j)==STdx && Status(i) == -1 )
          %     st(i) = j;
          %     Status(i) = Stat上为e-17，us(i)+1;
          % elseif (d(j)==EDdx && Status(i) == 0 )
          %     ed(i) = j;
          %     Status(i) = Status(i)+1;
          % end         
      end
  end

for i=1:nou
    if st(i)==0
        continue;
    end
    hold on;
    plot(orid(st(i)),p(st(i)),'-o','LineWidth',2);
    if ed(i)==0
        continue;
    end
    hold on;    
    plot(orid(ed(i)),p(ed(i)),'-o','LineWidth',2);
end

%% 精确找点
for  i=1:nou
    for j=st(i):st(i)+100*N
        if((d(j)-d(j-1))<=0 && p(j)<= p(st(i)) && d(j)>=d(st(i)))
            %disp("update");
            Status(i) = 100;      
            st(i)=j;
        end
    end

    for j=ed(i)-50*N:ed(i)+50*N
        if(d(j) <= d(ed(i)) && p(j)<= p(ed(i)))
            Status(i) = 200;      
            ed(i)=j;
        end
    end
end
   
figure(2);clf(2);
plot(d,p,'LineWidth',2);
hold on;

for i=1:nou
    if st(i)==0
        continue;
    end
    hold on;
    plot(orid(st(i)),p(st(i)),'-o','LineWidth',2);
    if ed(i)==0
        continue;
    end
    hold on;    
    plot(orid(ed(i)),p(ed(i)),'-o','LineWidth',2);
end

%%  柔度计算
C=[];                   %定义柔度数组C
for i=1:nou
    k=polyfit(d(st(i):ed(i)),p(st(i):ed(i)),1);
    xd=0:d(st(i));
    plot(xd,r(1)*xd+r(2));
    C(i)=1/k(i);
end

%%  公式和常量定义
E=206000;Bn=9.6;B=12;W=12;
Be=B-(B-Bn).^2/B;
u=((E.*Be.*C).^0.5+1).^-1;
a=(1.9215-13.2195.*u+58.7080.*u.^2-155.2823.*u.^3+207.3987.*u.^4-107.9176.*u.^5).*W;

%%  弹性、塑性部分面积计算

% x0=[0, 0.021708, 0.021708];     %选取计算点，即整个选取数据的第二个点。
% y0=[0, 23032.1992, 0];
A0=trapz(x0,y0);                  %计算柔度最低点（第一个计算点）的整个面积。
x1=0.021708;y1=23032.1992;        %柔度最低点（第一个计算点）的坐标，即整个选取数据的第二个点。
k=y1/x1;                          %载荷-位移曲线弹性部分的斜率,若不是弹性段，则选取开始阶段的部分计算斜率。
j0=(y1-k*x1)/(-k);                %过第一个计算点做与弹性部分平行的直线与X轴的交点。
tri0=(x1-j0)*y1/2;                %第一个计算点的弹性面积 
Ap0=A0-tri0;                      %第一个计算点的塑性面积 
a0=a(2); v=0.3;                   %说明试样第一个计算点的初始裂纹长度和试样尺寸；弹性模量与泊松比。

%%  迭代前的
Q=W^-1*B^-0.5*Bn^-0.5;
b0=W-a0;
n=1.067-1.767*(a0/W)+7.808*(a0/W)^2-18.269*(a0/W)^3+15.295*(a0/W)^4-3.083*(a0/W)^5;
G=1.197*(a0/W)^0-2.133*(a0/W)^1+23.886*(a0/W)^2-69.051*(a0/W)^3+100.462*(a0/W)^4-41.397*(a0/W)^5 ...
  -36.137*(a0/W)^6+51.215*(a0/W)^7-6.607*(a0/W)^8-52.322*(a0/W)^9+18.574*(a0/W)^10+19.465*(a0/W)^11;
Jp0=(n*Ap0)/(b0*Bn);
K0=(y0(3)*(3.1415926*a0)^0.5*(B*Bn)^-0.5*W^-1)*G;
Je0=(K0^2*(1-v^2))/E;

x= data(2:num,4);
y= data(2:num,3);
B=[];B(1)=Jp0;                    %B存储弹性部分J积分
C=[];C(1)=Jp0+Je0;                %C存储J积分总和，把第一个计算点的J积分值赋给C（1）。
b=W-a;
n1=1.067-1.767.*(a./W)+7.808.*(a./W).^2-18.269.*(a./W).^3+15.295.*(a./W).^4-3.083.*(a./W).^5;
n2=9.336-9.168.*(a./W)-143.889.*(a./W).^2+350.788.*(a./W).^3-224.375.*(a./W).^4;
n3=-0.623+9.336.*(a./W)-4.584.*(a./W).^2-47.963.*(a./W).^3+87.697.*(a./W).^4-44.875.*(a./W).^5;
G1=1.197.*(a./W).^0-2.133.*(a./W).^1+23.886.*(a./W).^2-69.051.*(a./W).^3+100.462.*(a./W).^4-41.397.*(a./W).^5 ...
   -36.137.*(a./W).^6+51.215.*(a./W).^7-6.607.*(a./W).^8-52.322.*(a./W).^9+18.574.*(a./W).^10+19.465.*(a./W).^11;

%% 迭代求Jth

for i=1:(num-2)
j1=(y(i)-k.*x(i))./(-k);
j2=(y(i+1)-k.*x(i+1))./(-k);
x2=[j1,x(i),x(i+1),j2];
y2=[0,y(i),y(i+1),0];
AZ=polyarea(x2,y2);          %求相邻计算点之间的增量面积。
J1=B(i)+(n1(i+1).*AZ)./(b(i+1).*Bn);
J2=-1+n3(i+1)-(b(i+1).*n2(i+1))./(W.*n3(i+1));
J3=1-(J2./b(i+1)).*(a(i+2)-a(i+1));
Jp=J1.*J3;
B(i+1)=Jp;
K=y(i+1).*(3.1415926.*a(i+2)).^0.5*Q.*G1(i+2);
Je=(K.^2.*(1-v^2))./E;
C(i+1)=Jp+Je;
end

for i=1:(num-2)


end



%% 输出迭代结果
CC = num2str(C(num-1));
strcat("J=",CC);
print(CC);
writelines(CC,'C.txt');


