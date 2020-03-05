%maindata     Ϊ��Ҫ�ж��¼�������
%win_width    Ϊ�������ڵĿ��
%level        Ϊ�������е�һ����ֵ
%powState     Ϊͬʱ��������������״̬


function [start_end, events] = MMP_detect( maindata ,win_width, level, powState)
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
    
    diff_data = diff(maindata);
    for i = 1:length( diff_data  )
        if( abs(diff_data(i)) < 20  )
            diff_data(i) = 0;
        end
    end
    %%%
    for i = 1:length(diff_data)
       if( (diff_data(i)~= 0) )
           j = i;
            while( diff_data(j)~= 0 )
                j = j+1;
            end
       end
       
            if( happen(j) == 0 )
                happen(j) = maindata(j);
            end  
    end
    
    for i = 1:1:length(happen)-1
        if( happen(i)~=0 )
            if( happen(i+1)~= 0)
                happen(i)= 0;
            end
        end
    end
    
    %���С��һ��ֵ���¼��ж�
    for i = 1:1:length(happen)
        if( happen(i) ~= 0 )
            down = max(1, i-3);
            up = min(i+3, length(happen));
            if( abs(maindata(up) - maindata(down) )< 10 )
                happen(i) =0;
            end
        end
    end

    %---------------------���ò�ֽ���ɸѡ-----------------------------------------
    
    %�õ����ݵĲ����ʽ�����öಽ��ֵõ�һ������ȶ��Ĳ������
    maindata_diff = 0.5 * diff_steps(maindata, 1) + 0.2 * diff_steps(maindata, 2) + 0.3 * diff_steps(maindata, 3);
%     powerLevel = zeros(powState,1); %����ͬʱ�������ظ������ΪpowState�������ʵ�λͬʱ�����ĸ���
%     checkRecord = zeros(powState,1); %��¼�����ص��±�λ��
%     flag = 0;%�����ؼ�¼��־��0Ϊ�ޣ�>0��ʾ��������
    check = find(happen ~= 0); %check Ϊhappen�����в�Ϊ����±ꣻ
    list_up = zeros(length(check), 6);
    list_down = zeros(length(check), 6);
    
    
    for i = 1 : length(check)
        index = check(i);
        if(maindata_diff(index) > 0) %��ִ����㣬�ж�Ϊ������
            list_up(i,:) = record_up(maindata, index, 5);
        elseif(maindata_diff(index) < 0) %�ж�Ϊ�½���
            list_down(i,:) = record_down(maindata, index, 5);
        else
            happen(index) = 0;
        end
    end
    
    list_up(list_up(:,1) == 0,:) = [];
    list_down(list_down(:,1) == 0,:) = [];
    
    start_end = checkRecord(list_up, list_down, powState);
    events = eventExtract(maindata, start_end, list_up, list_down);
end

