function changeIdx = binary_search_CSCshift(cscFileNames,searchRange)

while diff(searchRange)>20
    midpoint = round( mean(searchRange));
    [IdxLag1, r1] = calculate_channeldx_shift(cscFileNames, [searchRange(1) midpoint], 10);
    [IdxLag2, r2] = calculate_channeldx_shift(cscFileNames, [midpoint searchRange(2)], 10);
    if IdxLag1*IdxLag2 ==0
        if IdxLag1
            searchRange = [searchRange(1) midpoint];
        elseif IdxLag2
            searchRange = [midpoint searchRange(2)];
        else
            break;
        end
    else
        if r1>r2
            searchRange = [searchRange(1) midpoint];
        else
            searchRange = [midpoint searchRange(2)];
        end
    end
end
changeIdx = round( mean(searchRange));
