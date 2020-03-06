%���룺list_upΪһά������������
      %index�±꣬
      %indexǰnum�����ݵ�mu��ֵ��
      %index��num�����ݵ�mu��ֵ��
      %sigma_beforeǰnum�����ݵı�׼��
      %sigma_after��num�����ݵı�׼���׼�
      %diff_up�����ص����ݴ�С
      
      %list_downΪһά������������
      %index�±꣬
      %indexǰnum�����ݵ�mu��ֵ��
      %index��num�����ݵ�mu��ֵ��
      %sigma_beforeǰnum�����ݵı�׼��
      %sigma_after��num�����ݵı�׼���׼�
      %diff_down�����ص����ݴ�С

function events = eventExtract(power, start_end, list_up, list_down)

num_events = length(start_end);%�¼���ʽ
events = cell(num_events, 1);

for i = 1 : num_events
    %�¼�����ʼ
    begin = start_end(i,1);
    died = start_end(i,2);
    
    ori_pow = power;
    
    %�����ص��¼����
    up_indexes = find(start_end(:,1) > begin & start_end(:,1) < died);%�����������¼�����
    if(isempty(up_indexes))%Ϊ���򲻸ı�ԭ����
        ori_pow = ori_pow;
    else
        for j = 1 : length(up_indexes)
            index = up_indexes(j);
            up_begin = start_end(index, 1);%�¼��ı����ʼ��
            %�¼��ı����ֹ��
            if(start_end(index, 2) >= died)
                up_died = died;
            else
                up_died = start_end(index ,2);
            end
            
            if(start_end(index, 1) == start_end(index, 2))
                continue;
            end
            
            %�ҵ����¼���list_up��list_down�е�λ��
            up_where1 = find(list_up(:,1) == start_end(index, 1), 1);
            up_where2 = find(list_down(:,1) == start_end(index, 2), 1);
            %�¼�������ֵ
            value = 0.5 * (-(list_up(up_where1, 2) - list_up(up_where1,3)) + (list_down(up_where2, 2) - list_down(up_where2, 3)));
%             value = -list_up(up_where1, 6);
            
            ori_pow(up_begin : up_died) = ori_pow(up_begin : up_died) - value;
        end
    end
    
    down_indexes = find(start_end(:,2) > begin & start_end(:,2) < died);
    if(isempty(down_indexes))
        ori_pow = ori_pow;
    else
        for j = 1 : length(down_indexes)
            index = down_indexes(j);
            down_died = start_end(index, 2);
            if(start_end(index, 1) <= begin)
                down_begin = begin;
            else
                continue;
            end
            
            if(start_end(index, 1) == start_end(index, 2))
                continue;
            end
            
            down_where1 = find(list_up(:,1) == start_end(index, 1), 1);
            down_where2 = find(list_down(:,1) == start_end(index, 2), 1);
%             value = 0.5 * (-list_up(down_where1, 6) + list_down(down_where2, 6));
            value = 0.5 * (-(list_up(down_where1, 2) - list_up(down_where1,3)) + (list_down(down_where2, 2) - list_down(down_where2, 3)));
%             value = list_down(down_where2, 6);
            
            ori_pow(down_begin : down_died) = ori_pow(down_begin : down_died) - value;
        end
    end
    
    events{i} = ori_pow(begin : died);
    events{i} = medfilt1(events{i});
end

end