function [index, indexX] = getAnchorPulse(filename)

[data, eeg, eegSub, t] = getEasyEEGData(filename, 50);
figure;
title(filename);
plot(eegSub);

indexX = [];
%X = []; Y = [];
while 0<1
    [x,y,b] = ginput(1); 
    if isempty(b)
        break;
    elseif b==91
        ax = axis; width=ax(2)-ax(1); height=ax(4)-ax(3);
        axis([x-width/2 x+width/2 y-height/2 y+height/2]);
        zoom(1/2);
    elseif b==93
        ax = axis; width=ax(2)-ax(1); height=ax(4)-ax(3);
        axis([x-width/2 x+width/2 y-height/2 y+height/2]);
        zoom(2);    
    else
        fprintf(1, 'x,y= %f, %f\n', x, y);
        indexX = x;
 %       X=[X;x];
 %       Y=[Y;y];
    end
end
%[X Y]

index = input('What pulse index is this (1, 2, 3. ...)? ');

end