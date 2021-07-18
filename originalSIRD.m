T=100;
% %cGAMMA = 0.3;
% cGAMMA = 0.5;
% cTAU   = 0.2;
x=linspace(1,T,T);
S_y=zeros(1,T); %生産年齢の非陽性者配列(医療従事者含む)
S_e=zeros(1,T); %老人の非陽性者配列
IN_y=zeros(1,T); %生産年齢の通常株陽性者配列
ID_y=zeros(1,T); %生産年齢のデルタ株陽性者配列
IN_e=zeros(1,T); %老人の通常株陽性者配列
ID_e=zeros(1,T); %老人のデルタ株陽性者配列
R_y=zeros(1,T); %生産者の回復者配列
R_e=zeros(1,T); %老人の回復者配列
D_y=zeros(1,T); %死亡者配列生産者
D_e=zeros(1,T); %死亡者配列老人
V1_y=zeros(1,T); %生産者のワクチン1回目うった人配列
V1_e=zeros(1,T); %老人のワクチン一回目うったひと配列
V2_y=zeros(1,T); %生産者のワクチン2回目うったひと配列
V2_e=zeros(1,T); %老人のワクチン2回目うったひと配列
VN1_y=zeros(1,T); %ワクチン1回目の数生産用
VN2_y=zeros(1,T); %ワクチン2回目の数生産用
VN1_e=zeros(1,T); %ワクチン1回目の数老人用
VN2_e=zeros(1,T); %ワクチン2回目の数老人用
Vall=zeros(1,T); %ワクチンの合計本数 
VE1 = 0.3; %ワクチン1回の効果
VE2 = 0.87; %ワクチン2回の効果
INR_y=0.65; %生産年齢人口通常株感染率 元0.6 0.65
INR_e=0.32; %老人通常株感染率　元0.5 0.32
IDR_y=1.09; %生産デルタ株感染率 元1 1.09
IDR_e=0.54; %老人デルタ株感染率 元0.85 0.54
CR_y = 7/12; %回復率生産年齢 7/12を若者回復しやすいとして振り分け
CR_e = 0.4; %回復率老人
DR_y = 0.0022; %生産年齢人口死亡率 https://www.mhlw.go.jp/content/000807085.pdfより算出
DR_e = 0.096; %老人死亡率
VR_y = 1; %若者へのワクチン供給割合
VR_e = 1-VR_y; %老人へのワクチン供給割合
h_y = 0.8; %ワクチン接種希望者割合
VN_y_all = zeros(1,T); %若者へのワクチン供給数
VN_e_all = zeros(1,T); %老人へのワクチン供給数
alpha = zeros(1,T); %緊急事態宣言用モデル


%はじめの状態
IN_y(1)=0.00012;
IN_e(1)=0.000025;
ID_y(1)=0.00012*0.02;
ID_e(1)=0.000025*0.02;
D_y(1)=0.0000072;
D_e(1)=0.000060;
R_y(1)=0.0029;
R_e(1)=0.00059;
S_y(1)=0.778-IN_y(1)-D_y(1)-R_y(1);
S_e(1)=0.222-IN_e(1)-D_e(1)-R_e(1);
Vall(1)=0;
population = 127000000;
VNR1_y = transpose(VN1_y/population);
VNR1_e = transpose(VN1_e/population);
VNR2_y = transpose(VN2_y/population);
VNR2_e = transpose(VN2_e/population);
%%%%%%%%%%%%%%%ここでxlsx読み込んでもろて%%%%%%%%%%%%%%%
opts = detectImportOptions('C:\Users\maron\Documents\東大授業関連\経済2021\MATLAB\vaccine.xlsx');
opts.Sheet = '2_8_0.7';
opts.SelectedVariableNames = [1:4]; 
M = readmatrix('C:\Users\maron\Documents\東大授業関連\経済2021\MATLAB\vaccine.xlsx',opts);
VN1_y = M(:,1);
VN2_y = M(:,2);
VN1_e = M(:,3);
VN2_e = M(:,4);
VNR1_y = transpose(VN1_y/population);
VNR1_e = transpose(VN1_e/population);
VNR2_y = transpose(VN2_y/population);
VNR2_e = transpose(VN2_e/population);

p=zeros(1,T);
chokkin=zeros(1,T);
chokkin(1)=14000/population;

%ワクチン効くの遅いから2週間くらい下げてもヨシ
%ここからSIRD
for t=2:T
    if  (alpha(t) == 0) && (chokkin(t-1)*population >= 12000)
        alpha(t) = 0.2;
    elseif (alpha(t)==0) && (chokkin(t-1)*population>= 8000)
        alpha(t)=0.06;
        alpha(t+1)=0.06;
        alpha(t+2)=0.06;
    elseif (alpha(t) ==0)
        alpha(t)=0;
    else
    end
    S_y(t)=S_y(t-1)-(1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)-(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)-VNR1_y(t-1);
    S_e(t)=S_e(t-1)-(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)-(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)-VNR1_e(t-1);
    IN_y(t)=IN_y(t-1)+(1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)+(1-alpha(t-1))*(1-VE1)*INR_y*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)+(1-alpha(t-1))*(1-VE2)*INR_y*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)-CR_y*IN_y(t-1)-DR_y*IN_y(t-1);
    IN_e(t)=IN_e(t-1)+(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)+(1-alpha(t-1))*(1-VE1)*INR_e*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)+(1-alpha(t-1))*(1-VE2)*INR_e*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)-CR_e*IN_e(t-1)-DR_e*IN_e(t-1);
    ID_y(t)=ID_y(t-1)+(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)+(1-VE1)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)+(1-VE2)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1)-CR_y*ID_y(t-1)-DR_y*ID_y(t-1);
    ID_e(t)=ID_e(t-1)+(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)+(1-VE1)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)+(1-VE2)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1)-CR_e*ID_e(t-1)-DR_e*ID_e(t-1);
    V1_y(t)=V1_y(t-1)+ VNR1_y(t-1)-INR_y*(1-VE1)*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)-IDR_y*(1-VE1)*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)-VNR2_y(t-1);
    V1_e(t)=V1_e(t-1)+ VNR1_e(t-1)-INR_e*(1-VE1)*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)-IDR_e*(1-VE1)*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)-VNR2_e(t-1);
    V2_y(t)=V2_y(t-1)+ VNR2_y(t-1)-INR_y*(1-VE2)*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)-IDR_y*(1-VE2)*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1);
    V2_e(t)=V2_e(t-1)+ VNR2_e(t-1)-INR_e*(1-VE2)*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)-IDR_e*(1-VE2)*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1);
    R_y(t)=R_y(t-1)+CR_y*(IN_y(t-1)+ID_y(t-1));
    R_e(t)=R_e(t-1)+CR_e*(IN_e(t-1)+ID_e(t-1));
    D_y(t)=D_y(t-1)+DR_y*(IN_y(t-1)+ID_y(t-1));
    D_e(t)=D_e(t-1)+DR_e*(IN_e(t-1)+ID_e(t-1));
    p(t)=(1-alpha(t-1));
    chokkin(t) = (1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)+(1-alpha(t-1))*(1-VE1)*INR_y*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)+(1-alpha(t-1))*(1-VE2)*INR_y*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)+(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)+(1-alpha(t-1))*(1-VE1)*INR_e*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)+(1-alpha(t-1))*(1-VE2)*INR_e*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)+(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)+(1-VE1)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)+(1-VE2)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1)+(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)+(1-VE1)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)+(1-VE2)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1);

end

xticks([1 6 10 15 20 24 29 33 37 42 47 51 56 60 64 69 73 77 82 86 90 95]);
xticklabels({'4月1週','5月1週','6月1週','7月1週','8月1週','9月1週','10月1週','11月1週','12月1週', '1月1週', '2月1週','3月1週','4月1週','5月1週','6月1週','7月1週','8月1週','9月1週','10月1週','11月1週','12月1週', '1月1週', '2月1週'})
e=(IN_e+ID_e);
kansensya=ID_e+ID_y+IN_e+IN_y;
% plot(x,kansensya*population,'LineWidth',1.5,'Color','#0072BD');
% hold on 
plot(x,e*population,'LineWidth',1.5,'Color','#0072BD','LineStyle','-.');
hold on
% plot(x,(D_y+D_e)*population,'LineWidth',1.5,'Color','#0072BD','LineStyle',':');
% hold on
% plot(x,D_e*population,'LineWidth',1.5,'Color','#0072BD','LineStyle','-.');
% hold on
plot(x,chokkin*population,'LineWidth',1.5,'Color','#0072BD','LineStyle','-');
hold on
plot(x,(D_y+D_e)*population,'LineWidth',1.5,'LineStyle','--','Color','#0072BD');
hold on
% reproductiveness = zeros(1,T);
% a=5/7;
% for t=3;T
%     chokkin = (IN_y(t)+IN_e(t)+ID_y(t)+ID_e(t)-(IN_y(t-1)+IN_e(t-1)+ID_y(t-1)+ID_e(t-1)));
%     sonomae = (IN_y(t-1)+IN_e(t-1)+ID_y(t-1)+ID_e(t-1)-(IN_y(t-2)+IN_e(t-2)+ID_y(t-2)+ID_e(t-2)));
%     reproductiveness(t) = (chokkin/sonomae).^a;
% end
% plot(x,reproductiveness);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.Sheet = '8_2_0.7';
opts.SelectedVariableNames = [1:4]; 
M = readmatrix('C:\Users\maron\Documents\東大授業関連\経済2021\MATLAB\vaccine.xlsx',opts);
VN1_y = M(:,1);
VN2_y = M(:,2);
VN1_e = M(:,3);
VN2_e = M(:,4);
VNR1_y = transpose(VN1_y/population);
VNR1_e = transpose(VN1_e/population);
VNR2_y = transpose(VN2_y/population);
VNR2_e = transpose(VN2_e/population);

p=zeros(1,T);
chokkin=zeros(1,T);
chokkin(1)=14000/population;

%ワクチン効くの遅いから2週間くらい下げてもヨシ
%ここからSIRD
for t=2:T
    if  (alpha(t) == 0) && (chokkin(t-1)*population >= 12000)
        alpha(t) = 0.2;
    elseif (alpha(t)==0) && (chokkin(t-1)*population>= 8000)
        alpha(t)=0.06;
        alpha(t+1)=0.06;
        alpha(t+2)=0.06;
    elseif (alpha(t) ==0)
        alpha(t)=0;
    else
    end
    S_y(t)=S_y(t-1)-(1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)-(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)-VNR1_y(t-1);
    S_e(t)=S_e(t-1)-(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)-(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)-VNR1_e(t-1);
    IN_y(t)=IN_y(t-1)+(1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)+(1-alpha(t-1))*(1-VE1)*INR_y*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)+(1-alpha(t-1))*(1-VE2)*INR_y*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)-CR_y*IN_y(t-1)-DR_y*IN_y(t-1);
    IN_e(t)=IN_e(t-1)+(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)+(1-alpha(t-1))*(1-VE1)*INR_e*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)+(1-alpha(t-1))*(1-VE2)*INR_e*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)-CR_e*IN_e(t-1)-DR_e*IN_e(t-1);
    ID_y(t)=ID_y(t-1)+(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)+(1-VE1)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)+(1-VE2)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1)-CR_y*ID_y(t-1)-DR_y*ID_y(t-1);
    ID_e(t)=ID_e(t-1)+(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)+(1-VE1)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)+(1-VE2)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1)-CR_e*ID_e(t-1)-DR_e*ID_e(t-1);
    V1_y(t)=V1_y(t-1)+ VNR1_y(t-1)-INR_y*(1-VE1)*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)-IDR_y*(1-VE1)*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)-VNR2_y(t-1);
    V1_e(t)=V1_e(t-1)+ VNR1_e(t-1)-INR_e*(1-VE1)*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)-IDR_e*(1-VE1)*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)-VNR2_e(t-1);
    V2_y(t)=V2_y(t-1)+ VNR2_y(t-1)-INR_y*(1-VE2)*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)-IDR_y*(1-VE2)*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1);
    V2_e(t)=V2_e(t-1)+ VNR2_e(t-1)-INR_e*(1-VE2)*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)-IDR_e*(1-VE2)*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1);
    R_y(t)=R_y(t-1)+CR_y*(IN_y(t-1)+ID_y(t-1));
    R_e(t)=R_e(t-1)+CR_e*(IN_e(t-1)+ID_e(t-1));
    D_y(t)=D_y(t-1)+DR_y*(IN_y(t-1)+ID_y(t-1));
    D_e(t)=D_e(t-1)+DR_e*(IN_e(t-1)+ID_e(t-1));
    p(t)=(1-alpha(t-1));
    chokkin(t) = (1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)+(1-alpha(t-1))*(1-VE1)*INR_y*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)+(1-alpha(t-1))*(1-VE2)*INR_y*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)+(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)+(1-alpha(t-1))*(1-VE1)*INR_e*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)+(1-alpha(t-1))*(1-VE2)*INR_e*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)+(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)+(1-VE1)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)+(1-VE2)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1)+(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)+(1-VE1)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)+(1-VE2)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1);

end

xticks([1 6 10 15 20 24 29 33 37 42 47 51 56 60 64 69 73 77 82 86 90 95]);
xticklabels({'4月1週','5月1週','6月1週','7月1週','8月1週','9月1週','10月1週','11月1週','12月1週', '1月1週', '2月1週','3月1週','4月1週','5月1週','6月1週','7月1週','8月1週','9月1週','10月1週','11月1週','12月1週', '1月1週', '2月1週'})
e=(IN_e+ID_e);
kansensya=ID_e+ID_y+IN_e+IN_y;
% plot(x,kansensya*population,'LineWidth',1.5,'Color','#D95319')
% hold on
plot (x, e*population, 'LineWidth',1.5,'Color','#D95319','LineStyle','-.');
hold on
% plot(x,(D_y+D_e)*population,'LineWidth',1.5,'Color','#D95319','LineStyle',':');
% hold on
% plot(x,D_e*population,'LineWidth',1.5,'Color','#D95319','LineStyle','-.');
% hold on
plot(x,chokkin*population,'LineWidth',1.5,'Color','#D95319','LineStyle','-')
hold on
plot(x,(D_y+D_e)*population,'LineWidth',1.5,'Color','#D95319','LineStyle','--');
% legend('2:8新規感染者数','2:8死亡者数', '8:2新規感染者数', '8:2死亡者数','Location','southeast')
hold on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.Sheet = '1_1_0.7';
opts.SelectedVariableNames = [1:4]; 
M = readmatrix('C:\Users\maron\Documents\東大授業関連\経済2021\MATLAB\vaccine.xlsx',opts);
VN1_y = M(:,1);
VN2_y = M(:,2);
VN1_e = M(:,3);
VN2_e = M(:,4);
VNR1_y = transpose(VN1_y/population);
VNR1_e = transpose(VN1_e/population);
VNR2_y = transpose(VN2_y/population);
VNR2_e = transpose(VN2_e/population);

p=zeros(1,T);
chokkin=zeros(1,T);
chokkin(1)=14000/population;

%ワクチン効くの遅いから2週間くらい下げてもヨシ
%ここからSIRD
for t=2:T
    if  (alpha(t) == 0) && (chokkin(t-1)*population >= 12000)
        alpha(t) = 0.2;
    elseif (alpha(t)==0) && (chokkin(t-1)*population>= 8000)
        alpha(t)=0.06;
        alpha(t+1)=0.06;
        alpha(t+2)=0.06;
    elseif (alpha(t) ==0)
        alpha(t)=0;
    else
    end
    S_y(t)=S_y(t-1)-(1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)-(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)-VNR1_y(t-1);
    S_e(t)=S_e(t-1)-(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)-(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)-VNR1_e(t-1);
    IN_y(t)=IN_y(t-1)+(1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)+(1-alpha(t-1))*(1-VE1)*INR_y*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)+(1-alpha(t-1))*(1-VE2)*INR_y*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)-CR_y*IN_y(t-1)-DR_y*IN_y(t-1);
    IN_e(t)=IN_e(t-1)+(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)+(1-alpha(t-1))*(1-VE1)*INR_e*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)+(1-alpha(t-1))*(1-VE2)*INR_e*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)-CR_e*IN_e(t-1)-DR_e*IN_e(t-1);
    ID_y(t)=ID_y(t-1)+(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)+(1-VE1)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)+(1-VE2)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1)-CR_y*ID_y(t-1)-DR_y*ID_y(t-1);
    ID_e(t)=ID_e(t-1)+(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)+(1-VE1)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)+(1-VE2)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1)-CR_e*ID_e(t-1)-DR_e*ID_e(t-1);
    V1_y(t)=V1_y(t-1)+ VNR1_y(t-1)-INR_y*(1-VE1)*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)-IDR_y*(1-VE1)*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)-VNR2_y(t-1);
    V1_e(t)=V1_e(t-1)+ VNR1_e(t-1)-INR_e*(1-VE1)*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)-IDR_e*(1-VE1)*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)-VNR2_e(t-1);
    V2_y(t)=V2_y(t-1)+ VNR2_y(t-1)-INR_y*(1-VE2)*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)-IDR_y*(1-VE2)*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1);
    V2_e(t)=V2_e(t-1)+ VNR2_e(t-1)-INR_e*(1-VE2)*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)-IDR_e*(1-VE2)*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1);
    R_y(t)=R_y(t-1)+CR_y*(IN_y(t-1)+ID_y(t-1));
    R_e(t)=R_e(t-1)+CR_e*(IN_e(t-1)+ID_e(t-1));
    D_y(t)=D_y(t-1)+DR_y*(IN_y(t-1)+ID_y(t-1));
    D_e(t)=D_e(t-1)+DR_e*(IN_e(t-1)+ID_e(t-1));
    p(t)=(1-alpha(t-1));
    chokkin(t) = (1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)+(1-alpha(t-1))*(1-VE1)*INR_y*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)+(1-alpha(t-1))*(1-VE2)*INR_y*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)+(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)+(1-alpha(t-1))*(1-VE1)*INR_e*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)+(1-alpha(t-1))*(1-VE2)*INR_e*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)+(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)+(1-VE1)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)+(1-VE2)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1)+(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)+(1-VE1)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)+(1-VE2)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1);

end

xticks([1 6 10 15 20 24 29 33 37 42 47 51 56 60 64 69 73 77 82 86 90 95]);
xticklabels({'4月1週','5月1週','6月1週','7月1週','8月1週','9月1週','10月1週','11月1週','12月1週', '1月1週', '2月1週','3月1週','4月1週','5月1週','6月1週','7月1週','8月1週','9月1週','10月1週','11月1週','12月1週', '1月1週', '2月1週'})
e=(IN_e+ID_e);
kansensya=ID_e+ID_y+IN_e+IN_y;
% plot(x,kansensya*population,'LineWidth',1.5,'Color','#EDB120')
% hold on
plot(x,e*population,'LineWidth',1.5,'LineStyle','-.','Color','#EDB120');
hold on
% plot(x,(D_y+D_e)*population,'LineWidth',1.5,'LineStyle',':','Color','#EDB120');
% hold on
% plot(x,+D_e*population,'LineWidth',1.5,'LineStyle','-.','Color','#EDB120');
plot(x,chokkin*population,'LineWidth',1.5,'Color','#EDB120','LineStyle','-')
hold on
plot(x,(D_y+D_e)*population,'LineWidth',1.5,'LineStyle','--','Color','#EDB120');
hold on
% yyaxis right
%  plot (x,alpha,'LineWidth',1,'LineStyle','-.');
% yyaxis left
hold on
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.Sheet = '1_0_0.7';
opts.SelectedVariableNames = [1:4]; 
M = readmatrix('C:\Users\maron\Documents\東大授業関連\経済2021\MATLAB\vaccine.xlsx',opts);
VN1_y = M(:,1);
VN2_y = M(:,2);
VN1_e = M(:,3);
VN2_e = M(:,4);
VNR1_y = transpose(VN1_y/population);
VNR1_e = transpose(VN1_e/population);
VNR2_y = transpose(VN2_y/population);
VNR2_e = transpose(VN2_e/population);

p=zeros(1,T);
chokkin=zeros(1,T);
chokkin(1)=14000/population;

%ワクチン効くの遅いから2週間くらい下げてもヨシ
%ここからSIRD
for t=2:T
    if  (alpha(t) == 0) && (chokkin(t-1)*population >= 12000)
        alpha(t) = 0.2;
    elseif (alpha(t)==0) && (chokkin(t-1)*population>= 8000)
        alpha(t)=0.06;
        alpha(t+1)=0.06;
        alpha(t+2)=0.06;
    elseif (alpha(t) ==0)
        alpha(t)=0;
    else
    end
    S_y(t)=S_y(t-1)-(1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)-(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)-VNR1_y(t-1);
    S_e(t)=S_e(t-1)-(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)-(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)-VNR1_e(t-1);
    IN_y(t)=IN_y(t-1)+(1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)+(1-alpha(t-1))*(1-VE1)*INR_y*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)+(1-alpha(t-1))*(1-VE2)*INR_y*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)-CR_y*IN_y(t-1)-DR_y*IN_y(t-1);
    IN_e(t)=IN_e(t-1)+(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)+(1-alpha(t-1))*(1-VE1)*INR_e*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)+(1-alpha(t-1))*(1-VE2)*INR_e*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)-CR_e*IN_e(t-1)-DR_e*IN_e(t-1);
    ID_y(t)=ID_y(t-1)+(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)+(1-VE1)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)+(1-VE2)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1)-CR_y*ID_y(t-1)-DR_y*ID_y(t-1);
    ID_e(t)=ID_e(t-1)+(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)+(1-VE1)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)+(1-VE2)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1)-CR_e*ID_e(t-1)-DR_e*ID_e(t-1);
    V1_y(t)=V1_y(t-1)+ VNR1_y(t-1)-INR_y*(1-VE1)*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)-IDR_y*(1-VE1)*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)-VNR2_y(t-1);
    V1_e(t)=V1_e(t-1)+ VNR1_e(t-1)-INR_e*(1-VE1)*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)-IDR_e*(1-VE1)*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)-VNR2_e(t-1);
    V2_y(t)=V2_y(t-1)+ VNR2_y(t-1)-INR_y*(1-VE2)*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)-IDR_y*(1-VE2)*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1);
    V2_e(t)=V2_e(t-1)+ VNR2_e(t-1)-INR_e*(1-VE2)*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)-IDR_e*(1-VE2)*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1);
    R_y(t)=R_y(t-1)+CR_y*(IN_y(t-1)+ID_y(t-1));
    R_e(t)=R_e(t-1)+CR_e*(IN_e(t-1)+ID_e(t-1));
    D_y(t)=D_y(t-1)+DR_y*(IN_y(t-1)+ID_y(t-1));
    D_e(t)=D_e(t-1)+DR_e*(IN_e(t-1)+ID_e(t-1));
    p(t)=(1-alpha(t-1));
    chokkin(t) = (1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)+(1-alpha(t-1))*(1-VE1)*INR_y*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)+(1-alpha(t-1))*(1-VE2)*INR_y*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)+(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)+(1-alpha(t-1))*(1-VE1)*INR_e*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)+(1-alpha(t-1))*(1-VE2)*INR_e*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)+(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)+(1-VE1)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)+(1-VE2)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1)+(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)+(1-VE1)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)+(1-VE2)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1);

end

xticks([1 6 10 15 20 24 29 33 37 42 47 51 56 60 64 69 73 77 82 86 90 95]);
xticklabels({'4月1週','5月1週','6月1週','7月1週','8月1週','9月1週','10月1週','11月1週','12月1週', '1月1週', '2月1週','3月1週','4月1週','5月1週','6月1週','7月1週','8月1週','9月1週','10月1週','11月1週','12月1週', '1月1週', '2月1週'})
e=(IN_e+ID_e);
kansensya=ID_e+ID_y+IN_e+IN_y;
% plot(x,kansensya*population,'LineWidth',1.5,'Color','#7E2F8E')
% hold on
plot(x,e*population,'LineWidth',1.5,'LineStyle','-.','Color','#7E2F8E');
hold on
% plot(x,(D_y+D_e)*population,'LineWidth',1.5,'LineStyle',':','Color','#7E2F8E');
% hold on
% plot(x,D_e*population,'LineWidth',1.5,'LineStyle','-.','Color','#7E2F8E');
% hold on
plot(x,chokkin*population,'LineWidth',1.5,'Color','#7E2F8E','LineStyle','-')
hold on
plot(x,(D_y+D_e)*population,'LineWidth',1.5,'LineStyle','--','Color','#7E2F8E');
hold on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.Sheet = '0_1_0.7';
opts.SelectedVariableNames = [1:4]; 
M = readmatrix('C:\Users\maron\Documents\東大授業関連\経済2021\MATLAB\vaccine.xlsx',opts);
VN1_y = M(:,1);
VN2_y = M(:,2);
VN1_e = M(:,3);
VN2_e = M(:,4);
VNR1_y = transpose(VN1_y/population);
VNR1_e = transpose(VN1_e/population);
VNR2_y = transpose(VN2_y/population);
VNR2_e = transpose(VN2_e/population);

p=zeros(1,T);
chokkin=zeros(1,T);
chokkin(1)=14000/population;

%ワクチン効くの遅いから2週間くらい下げてもヨシ
%ここからSIRD
for t=2:T
    if  (alpha(t) == 0) && (chokkin(t-1)*population >= 12000)
        alpha(t) = 0.2;
    elseif (alpha(t)==0) && (chokkin(t-1)*population>= 8000)
        alpha(t)=0.06;
        alpha(t+1)=0.06;
        alpha(t+2)=0.06;
    elseif (alpha(t) ==0)
        alpha(t)=0;
    else
    end
    S_y(t)=S_y(t-1)-(1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)-(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)-VNR1_y(t-1);
    S_e(t)=S_e(t-1)-(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)-(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)-VNR1_e(t-1);
    IN_y(t)=IN_y(t-1)+(1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)+(1-alpha(t-1))*(1-VE1)*INR_y*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)+(1-alpha(t-1))*(1-VE2)*INR_y*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)-CR_y*IN_y(t-1)-DR_y*IN_y(t-1);
    IN_e(t)=IN_e(t-1)+(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)+(1-alpha(t-1))*(1-VE1)*INR_e*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)+(1-alpha(t-1))*(1-VE2)*INR_e*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)-CR_e*IN_e(t-1)-DR_e*IN_e(t-1);
    ID_y(t)=ID_y(t-1)+(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)+(1-VE1)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)+(1-VE2)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1)-CR_y*ID_y(t-1)-DR_y*ID_y(t-1);
    ID_e(t)=ID_e(t-1)+(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)+(1-VE1)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)+(1-VE2)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1)-CR_e*ID_e(t-1)-DR_e*ID_e(t-1);
    V1_y(t)=V1_y(t-1)+ VNR1_y(t-1)-INR_y*(1-VE1)*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)-IDR_y*(1-VE1)*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)-VNR2_y(t-1);
    V1_e(t)=V1_e(t-1)+ VNR1_e(t-1)-INR_e*(1-VE1)*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)-IDR_e*(1-VE1)*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)-VNR2_e(t-1);
    V2_y(t)=V2_y(t-1)+ VNR2_y(t-1)-INR_y*(1-VE2)*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)-IDR_y*(1-VE2)*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1);
    V2_e(t)=V2_e(t-1)+ VNR2_e(t-1)-INR_e*(1-VE2)*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)-IDR_e*(1-VE2)*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1);
    R_y(t)=R_y(t-1)+CR_y*(IN_y(t-1)+ID_y(t-1));
    R_e(t)=R_e(t-1)+CR_e*(IN_e(t-1)+ID_e(t-1));
    D_y(t)=D_y(t-1)+DR_y*(IN_y(t-1)+ID_y(t-1));
    D_e(t)=D_e(t-1)+DR_e*(IN_e(t-1)+ID_e(t-1));
    p(t)=(1-alpha(t-1));
    chokkin(t) = (1-alpha(t-1))*INR_y*(IN_y(t-1)+IN_e(t-1))*S_y(t-1)+(1-alpha(t-1))*(1-VE1)*INR_y*(IN_y(t-1)+IN_e(t-1))*V1_y(t-1)+(1-alpha(t-1))*(1-VE2)*INR_y*(IN_y(t-1)+IN_e(t-1))*V2_y(t-1)+(1-alpha(t-1))*INR_e*(IN_y(t-1)+IN_e(t-1))*S_e(t-1)+(1-alpha(t-1))*(1-VE1)*INR_e*(IN_y(t-1)+IN_e(t-1))*V1_e(t-1)+(1-alpha(t-1))*(1-VE2)*INR_e*(IN_y(t-1)+IN_e(t-1))*V2_e(t-1)+(1-alpha(t-1))*IDR_y*(ID_y(t-1)+ID_e(t-1))*S_y(t-1)+(1-VE1)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V1_y(t-1)+(1-VE2)*IDR_y*(ID_y(t-1)+ID_e(t-1))*V2_y(t-1)+(1-alpha(t-1))*IDR_e*(ID_y(t-1)+ID_e(t-1))*S_e(t-1)+(1-VE1)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V1_e(t-1)+(1-VE2)*IDR_e*(ID_y(t-1)+ID_e(t-1))*V2_e(t-1);

end

xticks([1 6 10 15 20 24 29 33 37 42 47 51 56 60 64 69 73 77 82 86 90 95]);
xticklabels({'4月1週','5月1週','6月1週','7月1週','8月1週','9月1週','10月1週','11月1週','12月1週', '1月1週', '2月1週','3月1週','4月1週','5月1週','6月1週','7月1週','8月1週','9月1週','10月1週','11月1週','12月1週', '1月1週', '2月1週'})
e=(IN_e+ID_e);
kansensya=ID_e+ID_y+IN_e+IN_y;
% plot(x,kansensya*population,'LineWidth',1.5,'Color','#77AC30','LineStyle','-')
% hold on
plot(x, e*population,'LineWidth',1.5,'LineStyle','-.','Color','#77AC30');
hold on
% plot(x,(D_y+D_e)*population,'LineWidth',1.5,'LineStyle',':','Color','#77AC30');
% hold on
% plot(x,D_e*population,'LineWidth',1.5,'LineStyle','-.','Color','#77AC30');
% legend('2:8感染者数','2:8高齢者感染者数','8:2感染者数','8:2高齢者感染者数','1:1感染者数','1:1高齢者感染者数','1:0感染者数','1:0高齢者感染者数','1:0死亡者数','1:0高齢者死亡者数','0:1感染者数','0:1高齢者感染者数','0:1死亡者数','0:1高齢者死亡者数','1:1時のα（右軸）','Location','southeast')
% plot(x,(D_y+D_e)*population,'LineWidth',1.5,'LineStyle','--','Color','#77AC30');
plot(x,chokkin*population,'LineWidth',1.5,'Color','#77AC30','LineStyle','-','Marker','none')
hold on
plot(x,(D_y+D_e)*population,'LineWidth',1.5,'LineStyle','--','Color','#77AC30','Marker','none');
legend('2:8高齢者感染者数','2:8新規感染者数','2:8死亡者数','8:2高齢者感染者数','8:2新規感染者数','8:2死亡者数','1:1高齢者感染者数','1:1新規感染者数','1:1死亡者数','1:0高齢者感染者数','1:0新規感染者数','1:0死亡者数','0:1高齢者感染者数','0:1高齢者感染者数','0:1新規感染者数','0:1死亡者数','1:1時のα（右軸）','Location','southeast')
hold on