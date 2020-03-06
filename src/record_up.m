%record_up �������ڼ�¼�¼�ǰ��������Ϣ

%���룺dataԭʼ���ݣ�index���ݽű꣬numѡȡ������ĸ���
%�����upΪһά������������
      %index�±꣬
      %indexǰnum�����ݵ�mu��ֵ��
      %index��num�����ݵ�mu��ֵ��
      %sigma_beforeǰnum�����ݵı�׼��
      %sigma_after��num�����ݵı�׼���׼�
      %diff_up�����ص����ݴ�С

function up = record_up(data, index, num)

limit = length(data);

low = max([index-num-3, 1]);
high = min([index+num, limit]);

mu_before = mean(data(low : index-1-3));
mu_after = mean(data(index + 1 : high));
sigma_before = var(data(low : index-1-3));
sigma_after = var(data(index + 1 : high));
diff_up = data(low) - data(high);%�ɳ��Ըı�
up = [index, mu_before, mu_after, sigma_before, sigma_after, diff_up]; 

end