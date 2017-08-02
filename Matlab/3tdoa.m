function [vektnew, dista, distb, distc] = tdoa(pa, pb, pc, ra, rb, rc)
    t=0:.01:2*pi;
    count = 0;
    %ersten Offset bestimmen
    distAB = sqrt((pa(1)-pb(1))^2 + (pa(2)-pb(2))^2);    
    diffAB = distAB - ra - rb;
    offset = diffAB / 2;
    %ersten Schnittpunkt bestimmen
    vektAB = pb-pa;
    schnittAB = pa + vektAB*((ra+offset)/distAB);
    %Abstand von LautsprecherC zu Schnittpunkt berechnen
    distABC = sqrt((schnittAB(1)-pc(1))^2 + (schnittAB(2)-pc(2))^2);
    %Überprüfen ob Offset passt
    diffABC = distABC - rc - offset;
    
    while abs(diffABC) > 0.02 && count < 20
        %wenn Differenz zu größ -> Offset anpassen 
        %Counter für maximal 20 Durchläufe setzen
        count = count + 1;
        offset = offset + diffABC/20;
        %Schnittpunkt mit neuem Offset berechnen (Kosinussatz)
        winkOffset = acosd(((rb+offset)^2-(ra+offset)^2-(distAB)^2) / (-2*(ra+offset)*distAB));
        winkAB = atand(vektAB(2)/vektAB(1));
        vektnew(1) = (ra+offset) * cosd(winkAB+winkOffset);
        vektnew(2) = (ra+offset) * sind(winkAB+winkOffset);
        %Differenz mit neuem Offset berechnen
        distABC = sqrt((vektnew(1)-pc(1))^2 + (vektnew(2)-pc(2))^2);
        diffABC = distABC - rc - offset;
    end
    dista = ra + offset;
    distb = rb + offset;
    distc = rc + offset;
end