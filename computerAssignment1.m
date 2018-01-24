function computerAssignment1
section = zeros();
sparType = zeros();
topCapped = zeros();
bottomCapped = zeros();
inputTitle = {'l1 (in meters)', 'l2 (in meters)'};
defaultValue = {'0.05', '0.10'};
type = chooseSection({'Closed', 'Open', 'Custom'}, 'Select section type');

if (strcmp(type, 'Closed'))
    section = chooseSection({'Inter-Spar Box', 'Wing Box'},...
        'Select closed section');
elseif (strcmp(type, 'Open'))
    section = chooseSection({'C', 'I', 'Z',...
        'invert L'}, 'Select open section');
else
    % Custom section
end

if (strcmp(section, 'Inter-Spar Box'))
    sparType = chooseSection({'Simple', 'C',...
        'I', 'Z', 'L', 'invert L'}, 'Select spar type');
end

if (strcmp(type, 'Closed') || strcmp(type, 'Open'))
    if (strcmp(type, 'Open') || strcmp(section, 'Wing Box'))
        inputTitle(end + 1) = {'t (in meters)'};
        defaultValue(end + 1) = {'0.01'};
    else
        inputTitle(end + 1) = {'t_spar (in meters)'};
        defaultValue(end + 1) = {'0.004'};
        inputTitle(end + 1) = {'t_skin (in meters)'};
        defaultValue(end + 1) = {'0.001'};
    end
    inputTitle(end + 1) = {'E_1 (in Pascal)'};
    defaultValue(end + 1) = {'70000000000'};
    [~ , E_at(1)] = size(inputTitle);
    inputTitle(end + 1) = {'E_2 (in Pascal)'};
    defaultValue(end + 1) = {'70000000000'};
    inputTitle(end + 1) = {'E_3 (in Pascal)'};
    defaultValue(end + 1) = {'70000000000'};
    
    if (strcmp(section, 'Wing Box'))
        inputTitle(end + 1) = {'E_4 (in Pascal)'};
        defaultValue(end + 1) = {'70000000000'};
        inputTitle(end + 1) = {'E_5 (in Pascal)'};
        defaultValue(end + 1) = {'70000000000'};
    end
    
    if (strcmp(section, 'Inter-Spar Box'))
        inputTitle(end + 1) = {'E_4 (in Pascal)'};
        defaultValue(end + 1) = {'70000000000'};
    end
    
    if (strcmp(type, 'Open'))
        [topCapped, bottomCapped] = chooseCap;
        if (topCapped)
            inputTitle(end + 1) = {'E_topCap (in Pascal)'};
            defaultValue(end + 1) = {'200000000000'};
        end
        
        if (bottomCapped)
            inputTitle(end + 1) = {'E_bottomCap (in Pascal)'};
            defaultValue(end + 1) = {'200000000000'};
        end
    end
    [~ , E_at(2)] = size(inputTitle);
end
inputTitle(end + 1) = {'Mx (in N-m)'};
defaultValue(end + 1) = {'0'};
inputTitle(end + 1) = {'My (in N-m)'};
defaultValue(end + 1) = {'200'};



parseInput(inputTitle, defaultValue, section,...
    sparType, topCapped, bottomCapped, E_at);
end

function section = chooseSection(section_choices, title)
d = dialog('Position',[300 300 250 150], ...
    'Name', title);
uicontrol('Parent', d, ...
    'Style','text', ...
    'Position',[20 80 210 40], ...
    'String','Select Section');

uicontrol('Parent',d, ...
    'Style','popup', ...
    'Position',[75 70 100 25], ...
    'String',section_choices, ...
    'Callback',@popup_callback);

uicontrol('Parent',d, ...
    'Position',[89 20 70 25], ...
    'String','Section', ...
    'Callback','delete(gcf)');

section = section_choices(1);

% Wait for d to close before running to completion
uiwait(d);

    function popup_callback(popup,~)
        idx = popup.Value;
        popup_items = popup.String;
        section = char(popup_items(idx,:));
    end
end

function [topCapped, bottomCapped] = chooseCap
d = dialog('Position', [300 300 250 220], ...
    'Name', 'Select cap');
uicontrol('Parent', d, ...
    'Style', 'text', ...
    'Position', [20 150 210 40], ...
    'String', 'Top capped');

uicontrol('Parent', d, ...
    'Style', 'popup', ...
    'Position', [75 140 100 25], ...
    'String', {'false', 'true'}, ...
    'Callback', @topCapped_callback);

uicontrol('Parent', d, ...
    'Style', 'text', ...
    'Position', [20 80 210 40], ...
    'String', 'Bottom capped');

uicontrol('Parent', d, ...
    'Style', 'popup', ...
    'Position', [75 70 100 25], ...
    'String', {'false', 'true'}, ...
    'Callback', @bottomCapped_callback);


uicontrol('Parent', d,...
    'Position', [89 20 70 25], ...
    'String', 'Section', ...
    'Callback', 'delete(gcf)');

topCapped = false;
bottomCapped = false;

% Wait for d to close before running to completion
uiwait(d);

    function topCapped_callback(popup,~)
        idx = popup.Value;
        popup_items = popup.String;
        if (strcmp(char(popup_items(idx,:)), 'true'))
            topCapped = true;
        else
            topCapped = false;
        end
    end

    function bottomCapped_callback(popup,~)
        idx = popup.Value;
        popup_items = popup.String;
        if (strcmp(char(popup_items(idx,:)), 'true'))
            bottomCapped = true;
        else
            bottomCapped = false;
        end
    end
end

function a = parseInput(inputTitle, defaultValue, section,...
    sparType, topCapped, bottomCapped, E_at)
% Ai(m, n, p) has stuctures as collection of rectangles
% diagonal point, Ai(:, :, p) correspond to rectangle p
% every point Ai(l, k, p), l = 1, 2 corresponding to any
% two correspoing diagonal vertices point corresponding
% to vertices of rectangle and k = 1, 2 correspond to y, z
% coodinate of that diagonal in order a----b  d-b or a-c
%                                                          | \/ |
%                                                          | /\ |
%                                                         d----c


Ei = zeros(E_at(2) + 2 - E_at(1), 1);
ti = zeros(E_at(1) - 3, 1);

[~,input_count] = size(inputTitle);
inputSize = zeros(input_count, 2);
for i = 1 : input_count
    inputSize(i, :) = [1 20];
end
data_str = inputdlg(inputTitle, 'Input Value', inputSize, defaultValue);

l1 = str2double(data_str(1));
l2 = str2double(data_str(2));

for i = 3 : (E_at(1) - 1)
    ti(i - 2) = str2double(data_str(i));
end

for i = E_at(1) : E_at(2)
    
    Ei(i + 1 - E_at(1)) = str2double(data_str(i));
end
if (topCapped && ~bottomCapped)
    Ei(5) = Ei(4);
end
if (bottomCapped && ~topCapped)
    Ei(5) = Ei(4);
end

M = zeros(2, 1);
[data_count, ~] = size(data_str);
M(1) = str2double(data_str(data_count - 1));
M(2) = str2double(data_str(data_count));
m = size(Ei);
if (strcmp(section, 'C'))
    Ai(:, :, 1) = [0, 0; ti, -l1];
    Ai(:, :, 2) = [ti, 0; (ti + l2), -ti];
    Ai(:, :, 3) = [(ti + l2), 0; (ti + l2 + ti), -l1];
    if (topCapped)
        Ai(:, :, 5) = [(ti + l2 + ti), 0; ((ti * 3) + l2), -l1];
    end
    if (bottomCapped)
        Ai(:, :, 4) = [-ti, 0; 0, -l1];
    end
elseif (strcmp(section, 'I'))
    Ai(:, :, 1) = [0, 0; ti, -l1];
    Ai(:, :, 2) = [ti, -((l1 - ti) / 2); (ti + l2), -((l1 + ti) / 2)];
    Ai(:, :, 3) = [(ti + l2), 0; (ti + l2 + ti), -l1];
    if (topCapped)
        Ai(:, :, 5) = [(ti + l2 + ti), 0; ((ti * 3) + l2), -l1];
    end
    if (bottomCapped)
        Ai(:, :, 4) = [-ti, 0; 0, -l1];
    end
elseif (strcmp(section, 'Z'))
    Ai(:, :, 1) = [0, 0; ti, -l1];
    Ai(:, :, 2) = [ti, 0; (ti + l2), -ti];
    Ai(:, :, 3) = [(ti + l2), -ti; (ti + l2 + ti), -(ti - l1)];
    if (topCapped)
        if (m < 5)
            disp('Ei has less element than expected, add 0 as 4th element')
            return;
        end
        Ai(:, :, 5) = [(ti + l2 + ti), -ti; ((ti * 3) + l2), -(ti - l1)];
    end
    if (bottomCapped)
        if (m < 3)
            disp('Ei has less element than expected')
            return;
        end
        Ai(:, :, 4) = [-ti, 0; 0, -l1];
    end
elseif (strcmp(section, 'invert L'))
    Ai(:, :, 1) = [0, 0; 0, 0];
    Ai(:, :, 2) = [0, 0; (0 + l2 - ti(1)), -ti(1)];
    Ai(:, :, 3) = [(l2 - ti(1)), 0; l2, -l1];
    
elseif (strcmp(section, 'Wing Box'))
    if (m < 3)
        disp('Ei has less element than expected')
        return;
    end
    t = zeros(6, 1);
    t(1) = ti;
    t(2) = ti;
    t(3) = ti;
    t(4) = ti;
    t(5) = ti;
    t(6) = ti;


    E = Ei;
    Ai(:, :, 1) = [0, 0; t(3), -(l2 + (2 * t(2)))];
    Ei(1) = E(1);
    Ai(:, :, 2) = [t(3), 0; (l1 + t(3)), -t(2)];
    Ei(2) = E(1);
    Ai(:, :, 3) = [(l1 + t(3)), 0; (l1 + t(3) + t(1)), -(l2 + (2* t(2)))];
    Ei(3) = E(1);
    Ai(:, :, 4) = [t(3), -(l2 + t(2)); (t(3) + l1), -(l2 + (2* t(2)))];
    Ei(4) = E(1);
    
    b = t(6);
    
    Ai(:, :, 5) = [t(3), -t(2); (t(3) + t(5)), -(t(2) + t(4) + b)];
    Ei(5) = E(2);
    Ai(:, :, 6) = [l1, -t(2); (t(5) + l1), -(t(2) + t(4) + b)];
    Ei(6) = E(2);
    Ai(:, :, 7) = [t(3), -(t(2) + l2 - t(4) - b);...
        (t(3) + t(5)), -(t(2) + l2)];
    Ei(7) = E(2);
    Ai(:, :, 8) = [l1, -(t(2) + l2 - t(4) - b); (t(5) + l1), -(t(2) + l2)];
    Ei(8) = E(2);
    Ai(:, :, 9) = [(t(3) + t(5)), -t(2); (t(3) + l1 - t(5)), -(t(2) + t(4))];
    Ei(9) = E(2);
    Ai(:, :, 10) = [(t(3) + t(5)), -(t(2) + l2 - t(4));...
        (t(3) + l1 - t(5)), -(t(2) + l2)];
    Ei(10) = E(2);
    
    Ai(:, :, 11) = zeros(2);
    Ei(11) = E(3);
    Ai(:, :, 12) = zeros(2);
    Ei(12) = E(3);
    Ai(:, :, 13) = zeros(2);
    Ei(13) = E(3);
    Ai(:, :, 14) = zeros(2);
    Ei(14) = E(3);
elseif (strcmp(section, 'Inter-Spar Box'))
    if (m < 3)
        disp('Ei has less element than expected')
        return;
    end
    t = zeros(2, 1);
    % t(1) is skin thickness
    % t(2) is spar thickness
    t(1) = ti(2);
    t(2) = ti(1);
    E = Ei;
    
    % Skin
    Ai(:, :, 1) = [0, 0; t(1), -(l2 + (2 * t(2)))];
    Ei(1) = E(1);
    Ai(:, :, 2) = [(l1 + t(1)), 0; (l1 + (2*t(1))), -(l2 + (2* t(2)))];
    Ei(2) = E(1);
    
    % Spar
    l3 = l2/4;
    if (strcmp(sparType, 'Simple'))
        Ai(:, :, 3) = [t(1), 0; (l1 + t(1)), -t(2)];
        Ei(3) = E(1);
        Ai(:, :, 4) = [t(1), -(l2 + t(2)); (t(1) + l1), -(l2 + (2* t(2)))];
        Ei(4) = E(1);
    elseif (strcmp(sparType, 'C'))
        Ai(:, :, 3) = [t(1), 0; (l1 + t(1)), -t(2)];
        Ei(3) = E(1);
        Ai(:, :, 5) = [t(1), -t(2); t(1) + t(2), -(l3 + t(2))];
        Ei(5) = E(1);
        Ai(:, :, 6) = [l1 + t(1) - t(2), -t(2); l1 + t(1), -(l3 + t(2))];
        Ei(6) = E(1);
        Ai(:, :, 4) = [t(1), -(l2 + t(2)); (t(1) + l1), -(l2 + (2* t(2)))];
        Ei(4) = E(1);
        Ai(:, :, 7) = [t(1), -(l2 + t(2) - l3); t(1) + t(2), -(l2 + t(2))];
        Ei(7) = E(1);
        Ai(:, :, 8) = [l1 + t(1) - t(2), -(l2 + t(2) - l3); l1 + t(1), -(l2 + t(2))];
        Ei(8) = E(1);
    elseif (strcmp(sparType, 'I'))
        Ai(:, :, 3) = [t(1), 0; (l1 + t(1)), -t(2)];
        Ei(3) = E(1);
        Ai(:, :, 5) = [t(1), -t(2); t(1) + t(2), -(l3 + t(2))];
        Ei(5) = E(1);
        Ai(:, :, 6) = [l1 + t(1) - t(2), -t(2); l1 + t(1), -(l3 + t(2))];
        Ei(6) = E(1);
        Ai(:, :, 9) = [t(1), 0; t(1) + t(2), l3];
        Ei(9) = E(1);
        Ai(:, :, 10) = [l1 + t(1) - t(2), 0; l1 + t(1) , l3];
        Ei(10) = E(1);
        Ai(:, :, 4) = [t(1), -(l2 + t(2)); (t(1) + l1), -(l2 + (2* t(2)))];
        Ei(4) = E(1);
        Ai(:, :, 7) = [t(1), -(l2 + t(2) - l3); t(1) + t(2), -(l2 + t(2))];
        Ei(7) = E(1);
        Ai(:, :, 8) = [l1 + t(1) - t(2), -(l2 + t(2) - l3); l1 + t(1), -(l2 + t(2))];
        Ei(8) = E(1);
        Ai(:, :, 11) = [t(1), -(l2 +(2*t(2))); t(1) + t(2), -(l2 + (2*t(2)) + l3)];
        Ei(11) = E(1);
        Ai(:, :, 12) = [l1 + t(1) - t(2), -(l2 +(2*t(2))); l1 + t(1), -(l2 + (2*t(2)) + l3)];
        Ei(12) = E(1);
    elseif (strcmp(sparType, 'Z'))
        Ai(:, :, 3) = [t(1), 0; (l1 + t(1)), -t(2)];
        Ei(3) = E(1);      
        Ai(:, :, 6) = [l1 + t(1) - t(2), -t(2); l1 + t(1), -(l3 + t(2))];
        Ei(6) = E(1);
        Ai(:, :, 9) = [t(1), 0; t(1) + t(2), l3];
        Ei(9) = E(1);
        Ai(:, :, 4) = [t(1), -(l2 + t(2)); (t(1) + l1), -(l2 + (2* t(2)))];
        Ei(4) = E(1);
        Ai(:, :, 7) = [l1 + t(1) - t(2), -(l2 + t(2) - l3); l1 + t(1), -(l2 + t(2))];
        Ei(7) = E(1);
        Ai(:, :, 5) = [t(1), -(l2 +(2*t(2))); t(1) + t(2), -(l2 + (2*t(2)) + l3)];
        Ei(5) = E(1);
    elseif (strcmp(sparType, 'L'))
        Ai(:, :, 3) = [t(1), 0; (l1 + t(1)), -t(2)];
        Ei(3) = E(1);
        Ai(:, :, 5) = [t(1), -t(2); t(1) + t(2), -(l3 + t(2))];
        Ei(5) = E(1);
        Ai(:, :, 4) = [t(1), -(l2 + t(2)); (t(1) + l1), -(l2 + (2* t(2)))];
        Ei(4) = E(1);
        Ai(:, :, 6) = [t(1), -(l2 + t(2) - l3); t(1) + t(2), -(l2 + t(2))];
        Ei(6) = E(1);
    else
        Ai(:, :, 3) = [t(1), 0; (l1 + t(1)), -t(2)];
        Ei(3) = E(1);
        Ai(:, :, 5) = [l1 + t(1) - t(2), -t(2); l1 + t(1), -(l3 + t(2))];
        Ei(5) = E(1);
        Ai(:, :, 4) = [t(1), -(l2 + t(2)); (t(1) + l1), -(l2 + (2* t(2)))];
        Ei(4) = E(1);
        Ai(:, :, 6) = [l1 + t(1) - t(2), -(l2 + t(2) - l3); l1 + t(1), -(l2 + t(2))];
        Ei(6) = E(1);
    end
end

l = l1 * 2;
if l2 > l1
    l = l2 * 2;
end

[~, ~, p] = size(Ai);

NPn = zeros(1, 2);
NPd = zeros(1);
gA = zeros(p, 2);
aA = zeros(p, 1);
IyyA = zeros(p, 1);
IyzA = zeros(p, 1);
IzzA = zeros(p, 1);
rA = zeros(p, 2);
EIyy = zeros(1);
EIyz = zeros(1);
EIzz = zeros(1);

figure;
for i = 1 : p
    A = Ai(: ,: ,i);
    height = A(2, 1) - A(1, 1);
    width = A(2, 2) - A(1, 2);
    if (height < 0)
        Az = (A(1,1) + height);
    else
        Az = A(1,1);
    end
    
    if (width < 0)
        Ay = (A(1,2) + width);
    else
        Ay = A(1,2);
    end
    E = Ei(i);
    
    color = E;
    while color > 1
        color = color * 0.1;
    end
    
    rectangle('Position', [Ay, Az, abs(width), abs(height)],...
        'FaceColor', [0.1 color color])
    
    g = centroid(A);
    gA(i, :) = g;
    
    a = areaRect(A);
    aA(i) = a;
    
    IyyA(i) = Itt(A, 'y');
    IzzA(i) = Itt(A, 'z');
    IyzA(i) = Itt(A, 'zy');
    
    NPn = NPn + (E * g * a);
    NPd = NPd + (E * a);
end

NP = NPn / NPd;

for i = 1 : p
    r = gA(i, :) - NP;
    rA(i, :) = r;
    
    E = Ei(i);
    a = areaRect(Ai(:,:,i));
    
    EIyy = EIyy + (E * (IyyA(i) + ((r(2) ^ 2) * a)));
    EIyz = EIyz + (E * (IyzA(i) + (r(1) * r(2) * a)));
    EIzz = EIzz + (E * (IzzA(i) + ((r(1) ^ 2) * a)));
end

%Error Correction
if (EIyz < 10^-10)
    EIyz = 0;
end

d = (EIzz * EIyy) - (EIyz ^ 2);

v = ((EIyz * M(1)) + (EIyy * M(2))) / d;
w = -((EIzz * M(1)) + (EIyz * M(2))) / d;


%max Stress
max1 = zeros(1);
maxPoint = zeros(2,1);
%yPoint = yPoint - NP(1);
%zPoint = zPoint - NP(2);
for n = 1 : p
    A = Ai(:, :, n);
    if A(1, 1) > A(2, 1)
        ym = A(1, 1);
        yl = A(2, 1);
    else
        ym = A(2, 1);
        yl = A(1, 1);
    end
    if A(1, 2) > A(2, 2)
        zm = A(1, 2);
        zl = A(2, 2);
    else
        zm = A(2, 2);
        zl = A(1, 2);
    end
    max2 = zeros(1);
    maxPoint2 = zeros(2, 1);
    y_increment = 0.1 * (abs(yl + ym) / 2);
    z_increment = 0.1 * (abs(zl + zm) / 2);


    %if (yPoint >= yl && yPoint <= ym && zPoint >= zl && zPoint <= zm) 
        %stressAtPoint = -Ei(n) * ((yPoint * v) + (zPoint * w))
    %end
    for j = yl : y_increment: ym
        max3 = zeros(1);
        maxPoint3 = zeros(2, 1);
        for k = zl : z_increment: zm
            P = [j, k];
            P = P - NP;
            stress = -Ei(n) * ((P(1) * v) + (P(2) * w));
            if (stress > max3 || max3 == 0)
                max3 = stress;
                maxPoint3 = P + NP;
            elseif stress == max3
                maxPoint3 = [maxPoint3 ; (P + NP)];%#ok<AGROW>
            end
        end
        if (max3 > max2 || max2 == 0)
            max2 = max3;
            maxPoint2 = maxPoint3;
        elseif (max3 == max2)
            maxPoint2 = [maxPoint2 ; maxPoint3];%#ok<AGROW>
        end
    end
    if ((max1 == 0 && max2 ~= 0) || (max2 > max1))
        max1 = max2;
        maxPoint = maxPoint2;
    elseif (max2 == max1)
        maxPoint = [maxPoint ; maxPoint2]; %#ok<AGROW>
    end
end

maxStr = max1;
%max Stress end

left_margin_2 =  l - (0.2 * (l/4));
if (strcmp(section, 'Inter-Spar Box'))
    X = ['t = ', mat2str(ti)];
    text(left_margin_2, l/4, X)
else
    X = ['t = ', num2str(ti)];
    text(left_margin_2, l/4, X)
end

X = ['l1 = ', num2str(l1)];
text(left_margin_2, 1.5 *(l/4), X)

X = ['l2 = ', num2str(l2)];
text(left_margin_2, l / 2, X)

X = ['M = (', num2str(M(1)), ' , ' ,num2str(M(2)),') '];
text(left_margin_2, 2.5 * (l/4), X)

if (topCapped && bottomCapped)
    X = ['Top and', ' bottom capped'];
    text(left_margin_2, 0.5* (l/4), X)
elseif(bottomCapped)
    X = ['Bottom ', 'capped'];
    text(left_margin_2, 0.5* (l/4), X)
elseif(topCapped)
    X = ['Top ', 'capped'];
    text(left_margin_2, 0.5* (l/4), X)
end
if ~strcmp('Wing Box', section)
    if (topCapped && bottomCapped)
        X = ['E = (', num2str(Ei(1)), ' ,', num2str(Ei(2)),...
            ' ,', num2str(Ei(3)),' ,', num2str(Ei(4)),' ,',...
            num2str(Ei(5)), ')'];
        text(left_margin_2, 3* (l/4), X)
    elseif(bottomCapped)
        X = ['E = (', num2str(Ei(1)), ' ,', num2str(Ei(2)), ' ,',...
            num2str(Ei(3)),' ,', num2str(Ei(5)), ')'];
        text(left_margin_2, 3* (l/4), X)
    elseif(topCapped)
        X = ['E = (', num2str(Ei(1)), ' ,', num2str(Ei(2)), ' ,',...
            num2str(Ei(3)),' ,', num2str(Ei(4)), ')'];
        text(left_margin_2, 3* (l/4), X)
    else
        X = ['E = (', num2str(Ei(1)), ' ,', num2str(Ei(2)), ' ,',...
            num2str(Ei(3)), ')'];
        text(left_margin_2, 3* (l/4), X)
    end
else
    X = ['E = (', num2str(Ei(1)), ' ,', num2str(Ei(2)), ' ,', num2str(Ei(3)), ')'];
    text(left_margin_2, 3* (l/4), X)
end


text(left_margin_2, 3.5 * (l/4), 'Given Data:')

X = ['NP = (', num2str(NP(1)), ' , ', num2str(NP(2)), ')'];
text(left_margin_2, -l + (0.5 * (l/4)), X)
X = ['EIyy = ', num2str(EIyy)];
disp(X)
text(left_margin_2, -l + (1 * (l/4)),X)
X = ['EIzz = ', num2str(EIzz)];
disp(X)
text(left_margin_2, -l + (1.5 * (l/4)), X)
X = ['EIyz = ', num2str(EIyz)];
disp(X)
text(left_margin_2, -l + (2 * (l/4)), X)
X = ['\sigma_{xx,max} = ', num2str(maxStr)];
disp(X)
text(left_margin_2, -l + ((2.5) * (l/4)), X)

left_margin_1 = -(0.5 * (l/4));
for i = 1 : p
    yCf = - Ei(i) * v;
    zCf = - Ei(i) * w;
    
    X = [ 'For z \in [', num2str(Ai(1, 2, i)), ' , ',...
        num2str(Ai(2, 2, i)), '] \cap y \in [', num2str(Ai(1, 1, i)),...
        ' , ', num2str(Ai(2, 1, i)), ']'];
    text(left_margin_1, -l + (1.2*(3/p) * (i) * (l/4)), X)
    disp(X)
    
    
    X = ['\sigma_{xx} = (', num2str(yCf), ' * (y - (', num2str(NP(1)), '))) + (',...
        num2str(zCf), ' * (z - ( ', num2str(NP(2)) , ')))'];
    text(left_margin_1, -l + (1.2*(3/p) * (i - 0.5) * (l/4)), X)
    disp(X)
end
hold on
axis(([(-l) l (-l) l]))
plot(NP(2), NP(1),'r*');
plot(maxPoint(:, 2), maxPoint(:, 1), 'b*');
legend('Neutral Point', 'Max Stress')
xlabel('Z axis')
ylabel('Y axis')
ax = gca;
set(gca,'XDir','Reverse')
set(gca, 'yaxislocation', 'left');
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';

stressAtCustomPoint(v, w, Ei, NP, zeros(), Ai);
hold off
end

function stress = stressAtCustomPoint(v, w, Ei, NP, plotOfCustomPoint, Ai)

if (plotOfCustomPoint ~= zeros())
    delete(plotOfCustomPoint);
end
inputTitle = {'Y cordinate', 'Z cordinate'};
defaultValue = {'0.0', '-0.0'};
[~,input_count] = size(inputTitle);
inputSize = zeros(input_count, 2);
for i = 1 : input_count
    inputSize(i, :) = [1 20];
end
data_str = inputdlg(inputTitle, 'Choose Point', inputSize, defaultValue);
yPoint = str2double(data_str(1));
zPoint = str2double(data_str(2));
i = checkPointInRect(Ai, yPoint, zPoint);
plotOfCustomPoint = plot(zPoint, yPoint , 'g*');
legend('Neutral Point', 'Max Stress','Point of Interest');
[~, iCount] = size(i);
if (i == 0)
    print = 'Coordinates not lie in any rectangular section!';
    choice = questdlg(print, 'Error',...
    'Another Point', 'Dismiss', 'Dismiss');
    if (~strcmp(choice, 'Dismiss'))
        stressAtCustomPoint(v, w, Ei, NP, plotOfCustomPoint, Ai);
    end
    return;
end
yCf = - Ei(i(1)) * v;
zCf = - Ei(i(1)) * w;
stress = (yCf * (yPoint - NP(1))) + (zCf * (zPoint - NP(2)));
if (iCount > 1)
    for p = 2 : iCount
        yCf = - Ei(i(p)) * v;
        zCf = - Ei(i(p)) * w;
        stress = [stress ((yCf * (yPoint - NP(1))) + (zCf * (zPoint - NP(2))))]; %#ok<AGROW>
    end
end
showStressAtCustomPoint(stress, yPoint, zPoint,...
    v, w, Ei, NP, plotOfCustomPoint, Ai);
end

function showStressAtCustomPoint(stress, Y, Z, v, w,...
    Ei, NP, plotOfCustomPoint, Ai)

print = ['Stress at (', num2str(Y), ', ', num2str(Z), ') = ',...
    num2str(stress(1))];
[~, stressCount] =  size(stress);
if (stressCount > 1)
    for p = 2 : stressCount
        print = [print, ' and ', num2str(stress(p))]; %#ok<AGROW>
    end
    print = [print, ' at interface'];
end
choice = questdlg(print, 'Stress at custom point',...
    'Another Point', 'Dismiss', 'Dismiss');
if (~strcmp(choice, 'Dismiss'))
    stressAtCustomPoint(v, w, Ei, NP, plotOfCustomPoint, Ai);
end
end

function a = checkPointInRect(Ai, Y, Z)
[~, ~, p] = size(Ai);
a = zeros();
for i = 1 : p
    A = Ai(:, :, i);
    if ((((A(1,1) - Y) * (A(2, 1) - Y)) <= 0) &&...
        (((A(1,2) - Z) * (A(2, 2) - Z)) <= 0))
        if (a == zeros())
            a = i;
        else
            a = [a i]; %#ok<AGROW>
        end        
    end
end
end

function g = centroid(A)
g = mean(A);
end

function a = areaRect(A)

b = A(1, 2) - A(2, 2);
h = A(1, 1) - A(2, 1);

a = abs(h * b);
end

function i = Itt(A, z)

b = abs(A(1, 2) - A(2, 2));
h = abs(A(1, 1) - A(2, 1));

if z == 'z'
    i = (b * (h ^ 3)) / 12;
elseif z == 'y'
    i = ((b ^ 3) * h) / 12;
else
    i = 0;
end
end
