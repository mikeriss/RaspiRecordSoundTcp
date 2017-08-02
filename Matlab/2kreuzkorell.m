function [kreuzkorell1, kreuzkorell2, kreuzkorell3] = kreuzkorell( record,sig1, sig2, sig3, FS)
    %Kreuzkorrelation durchführen
    [r1,lags1] = xcorr(record,sig1(:,1));
    [r2,lags2] = xcorr(record,sig2(:,1));
    [r3,lags3] = xcorr(record,sig3(:,1));
    %Punkt mit größter Korrelation ermitteln
    [x1,diff1] = max(abs(r1));
    kreuzkorell1 = lags1(diff1);
    [x2,diff2] = max(abs(r2));
    kreuzkorell2 = lags2(diff2);
    [x3,diff3] = max(abs(r3));
    kreuzkorell3 = lags3(diff3);
end

