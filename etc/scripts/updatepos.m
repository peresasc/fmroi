
function st = updatepos(st)


% function centre = findcent

centre = [];
cent   = [];
cp     = [];
for j=1%:3
    %     if (st.vols{i}.ax{j}.ax == obj)
    cp = get(gca,'CurrentPoint');
    %     end
    
    if ~isempty(cp)
        cp   = cp(1,1:2);
        is   = inv(st.Space);
        cent = is(1:3,1:3)*st.centre(:) + is(1:3,4);
        switch j
            case 1
                cent([1 2])=[cp(1)+st.bb(1,1)-1 cp(2)+st.bb(1,2)-1];
            case 2
                cent([1 3])=[cp(1)+st.bb(1,1)-1 cp(2)+st.bb(1,3)-1];
            case 3
                if st.mode ==0
                    cent([3 2])=[cp(1)+st.bb(1,3)-1 cp(2)+st.bb(1,2)-1];
                else
                    cent([2 3])=[st.bb(2,2)+1-cp(1) cp(2)+st.bb(1,3)-1];
                end
        end
        break;
    end
end

if ~isempty(cent)
    centre = st.Space(1:3,1:3)*cent(:) + st.Space(1:3,4);
end

st.centre = centre(1:3);

