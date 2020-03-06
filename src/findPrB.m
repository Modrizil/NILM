%Smean      Ϊ��ֵ̬��ͳ��ƽ����
%range      ��ֵ�Ĳ�����Χ
%data       Ϊ�ַ�������ʾ��ǰ���ĸ������в�ѯ

%name       ����õ����ķ�������
%Pr         Ϊ���������ڷֲ��еĸ���
%confidence Ϊ�÷����жϵ��������ų̶�

function [name Pr confidence] = findPrB(Smean,range,data)

dist = load([data '_dist.mat']);
load('musigma.mat');

if(strcmp(data, 'data3')==1)
    musigma = musigma3;
elseif(strcmp(data, 'data4')==1)
    musigma = musigma4;
end

len = length(musigma);
pd = cell(len, 1);

for i = 1 : len
    eval(['pd{i} = dist.' musigma{i,1} ';']);
end

[name Pr index] = matchMaxPr(musigma, Smean, range, pd);

target = musigma(index, 2);
target = cell2mat(target);
up = target(:,1) + target(:,2) / 2;
down = target(:,1) - target(:,2) / 2;

len = size(target,1);
TP = min([up, ones(len,1)*range(2)], [], 2) - max([down, ones(len,1)*range(1)], [], 2);
P = TP ./ (range(:,2) - range(:,1));
R = TP ./ (up - down);

confidence = 2 .* P .* R ./ (P + R);

end

function [name Pr index] = matchMaxPr(musigma, Smean, range, pd);

len = length(musigma);
difference = zeros(len, 1);
allPr = zeros(len, 1);

for i = 1 : len
    difference(i) = Smean - musigma{i, 2}(1);
    allPr(i) = cdf(pd{i}, range(2)) - cdf(pd{i}, range(1));
end
difference = abs(difference);

judge = allPr  + ones(len,1) ./ difference;


[judge_sort ori_index] = sort(judge, 'descend');


name = musigma(ori_index(1:5), 1);
Pr = allPr(ori_index(1:5));
index = ori_index(1:5);

end