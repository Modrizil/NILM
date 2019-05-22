%maindata     Ϊ��Ҫ�ж��¼�������
%win_width    Ϊ�������ڵĿ��
%level        Ϊ�������е�һ����ֵ
%powState     Ϊͬʱ��������������״̬


function [happen, start_end] = MMP_detect( maindata ,win_width, level, powState)
    %---------------���ô��ڻ�������ȡ������÷�����ʵ���¼����ж�---------------------
    %��ʼ��window����%����һ�����ھ���
    maindata = medfilt1(maindata,win_width);
    window = maindata([1:1:win_width]);
    varwindow = zeros(1,win_width);
    var_maindata = zeros(1,length(maindata));
    happen = zeros(1,length(maindata));
    time = 0;
    for i = 1:length(maindata) 
        if( (win_width-1+i) <= length(maindata)  )%û�е��׵Ļ�
            
            window = maindata([i:1:win_width-1+i]);%���´���
            
        else 
            window =window; 
        end
        
        vartemp = var(window);%���㻬�����ڷ���
        varwindow( mod(i,win_width)+1 ) = vartemp;%�ѻ������ڵķ�����������  
        
        if( i > win_width )
            sigma =   (vartemp - mean(varwindow))/mean(varwindow);
            if( sigma > level)
               time  = time + 1;
               happen(i+win_width-1) = maindata(i+win_width-1);
            end
            var_maindata(i) = vartemp;
        end

    end

    %---------------------���ò�ֽ���ɸѡ----------------------------------
    
    %�õ����ݵĲ����ʽ�����öಽ��ֵõ�һ������ȶ��Ĳ������
    maindata_diff = 0.8 * diff_steps(maindata, 1) + 0.2 * diff_steps(maindata, 2); %+ 0.3 * diff_steps(maindata, 3);
    powerLevel = zeros(powState,1); %����ͬʱ�������ظ������ΪpowState�������ʵ�λͬʱ�����ĸ���
    checkRecord = zeros(powState,1); %��¼�����ص��±�λ��
    flag = 0;%�����ؼ�¼��־��0Ϊ�ޣ�>0��ʾ��������
    check = find(happen ~= 0); %check Ϊhappen�����в�Ϊ����±ꣻ
    start_end = zeros(length(check), 2); %���������رյĶ�Ӧ��
    
    for i = 1 : length(check)
        index = check(i);
        if(maindata_diff(index) > 0) %��ִ����㣬�ж�Ϊ������ 
            p_index = find(powerLevel == 0, 1); 
            if(~isempty(p_index)) %�жϻ��ܲ�����������
                powerLevel(p_index) = maindata_diff(index);
                checkRecord(p_index) = index;
                flag = flag + 1;
            else
                happen(index) = 0;
            end
        elseif(maindata_diff(index) < 0) %�ж�Ϊ�½���
            if(flag > 0)
                if(isturndown(index, maindata)) %�жϺ���״̬�Ƿ�Ϊ��ȫ�ر�״̬���ǵĻ�������������������
                    s_index = find(start_end(:,1)==0, 1);
                    p_index = find(powerLevel ~= 0);
                    start_end([s_index : s_index + length(p_index) - 1], :) = [checkRecord(p_index), index * ones(length(p_index),1)];
                    
                    powerLevel(p_index) = 0;
                    checkRecord(p_index) = 0;
                    flag = 0;
                else %ƥ���Ӧ���½���
                    cmpLevel = powerLevel + maindata_diff(index) * ones(powState,1);
                    varLevel = var(maindata_diff(max(index-9, 1) : index));
                    cmpResult = (abs(cmpLevel) < 1.3 * varLevel ^ 0.5);
                    p_index = find(cmpResult == 1,1);
                    if(~isempty(p_index))
                        flag = flag - 1;
                        s_index = find(start_end(:,1)==0, 1);
                        start_end(s_index, :) = [checkRecord(p_index) index];
                        checkRecord(p_index) = 0;
                        powerLevel(p_index) = 0;
                    else
                        happen(index) = 0;
                    end
                end
            else
                happen(index) = 0;
            end
        else
            happen(index) = 0;
        end
    end
    
    %��û�������������ؼ�¼����
    p_index = find(powerLevel ~= 0);
    if(~isempty(p_index))
        s_index = find(start_end(:,1)==0, 1);
        start_end([s_index : s_index + length(p_index) - 1], :) = [checkRecord(p_index), zeros(length(p_index),1)];
    end
    
    s_index = find(start_end(:,1)==0);
    start_end(s_index, :) = [];
%plot(maindata,'-b');
%hold on 
  plot(happen,'r');
end

function answer = isturndown(index, maindata)
    
len = length(maindata);
if(index == len)
    if(maindata(index)<2)
        answer = 1;
    else
        answer = 0;
    end
else 
    later_mean = mean(maindata(index + 1 : min(len, index + 10)));
    later_var = var(maindata(index + 1 : min(len, index + 10)));
    if(later_mean + later_var^0.5 < 3)
        answer = 1;
    else 
        answer = 0;
    end
end

end