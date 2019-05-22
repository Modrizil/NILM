
function happen = MMP_detect_ori( maindata )
    %��ʼ��window����%����һ�����ھ���
    maindata = smooth(maindata,10);
    window = maindata([1:1:10]);
    varwindow = zeros(1,10);
    var_maindata = zeros(1,length(maindata));
    happen = zeros(1,length(maindata));
    time = 0;
    for i = 1:length(maindata) 
        if( (9+i) <= length(maindata)  )%û�е��׵Ļ�
            
            window = maindata([i:1:9+i]);%���´���
            
        else 
            window =window; 
        end
        
        vartemp = var(window);%���㻬�����ڷ���
        varwindow( mod(i,10)+1 ) = vartemp;%�ѻ������ڵķ�����������  
        
        if( i > 10 )
              sigma =   (vartemp - mean(varwindow))/mean(varwindow);
              if( sigma > 4.5)
                   time  = time + 1;
                   happen(i+9) = maindata(i+9);
          
        end
        var_maindata(i) = vartemp;
        end

    end
    for i = 1:1:length(happen)
        if( happen(i) ~= 0 )
            if( abs(maindata(i+3) - maindata(i-3) )< 4 )
                happen(i) =0;
            end
        end
    end
%plot(maindata,'-b');
%hold on 
  plot(happen,'r');
