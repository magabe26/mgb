import QtQuick 2.14
import QtQuick.Shapes 1.14

Rectangle {
    id: root
    width: 860; height: 980
    color: "#090f18"

    // Coordinate space: all paths stored in 0..1000 x 0..1000
    // sx/sy scale them to mapArea's actual pixel size at runtime
    readonly property real sx: mapArea.width  / 1000.0
    readonly property real sy: mapArea.height / 1000.0

    property string selectedRegion: ""
    property var    selectedData:   ({})
    property string hoveredRegion:  ""

    // ── Region coordinate arrays (flat: x0,y0,x1,y1,...) in 0–1000 space ──
    property var regionData: ({
        "Kagera": [460.7,0.0,268.4,0.0,253.6,15.0,247.6,31.2,250.0,52.3,160.0,55.0,160.3,87.7,172.1,109.6,177.2,146.2,173.6,167.3,160.3,172.7,161.5,220.7,179.6,221.0,182.1,211.4,189.6,209.6,203.8,235.7,205.3,252.6,217.7,251.7,225.8,242.3,244.9,245.6,259.4,236.9,267.2,238.4,271.1,219.2,250.6,200.3,251.8,168.2,244.3,164.3,246.1,144.1,241.5,139.3,262.1,56.5,431.5,54.4,444.4,60.7,453.8,41.4,443.5,25.2,453.2,8.1,463.2,4.2],
        "Mwanza": [225.8,240.2,230.1,258.6,233.7,255.6,240.3,255.6,248.5,259.2,260.0,260.1,262.1,263.1,262.1,272.1,273.6,274.8,280.8,287.7,293.2,291.3,298.6,289.5,301.9,291.3,316.1,291.9,321.6,290.1,324.0,291.9,327.3,288.0,338.2,285.6,343.6,291.6,365.6,290.1,369.6,291.9,371.4,279.3,369.3,276.9,369.3,272.1,375.9,269.1,376.5,261.0,381.0,258.3,376.2,256.8,364.7,258.9,350.2,249.2,333.3,247.4,329.4,255.3,324.0,257.7,317.6,253.8,317.0,247.7,312.5,243.2,307.7,243.5,300.1,248.6,287.7,242.9,272.3,242.9,262.4,237.5,240.0,246.5,233.7,242.9,233.7,239.0,237.0,236.3,238.2,231.2,231.6,231.5],
        "Mara": [372.3,146.2,372.9,152.0,380.1,151.1,386.2,154.7,406.7,155.6,411.5,152.3,413.3,146.5,419.4,145.6,425.4,153.5,432.1,153.8,440.2,159.2,440.8,172.4,442.3,162.8,450.5,160.7,463.5,163.1,484.0,179.6,538.0,180.2,547.4,114.4,478.9,76.9,458.3,62.8,448.4,58.0,442.0,58.6,436.3,61.6,436.0,66.7,430.9,73.0,431.2,81.7,420.0,87.1,419.7,96.7,412.4,100.6,413.6,110.8,405.8,113.2,405.2,119.8,391.6,131.5,385.3,140.5,376.8,139.0],
        "Simiyu": [536.5,183.5,485.2,183.2,480.1,181.4,477.4,174.8,463.8,163.4,440.2,159.2,439.9,170.6,423.0,183.8,406.1,184.7,404.6,192.5,409.7,196.1,409.1,203.0,397.0,210.5,391.3,245.3,382.5,254.7,377.1,255.6,373.2,260.7,373.8,267.0,366.8,269.7,372.0,280.5,369.9,287.4,364.1,289.5,356.0,283.5,352.1,301.8,335.1,303.0,364.1,304.2,377.4,300.9,409.1,300.6,426.6,306.6,428.7,311.1,444.7,314.1,451.1,321.3,460.7,321.0,469.2,314.4,473.4,304.8,490.9,300.9,494.3,285.9,514.2,279.3,514.5,224.6,520.8,221.9,526.3,225.8,531.4,222.5,535.0,211.4],
        "Shinyanga": [228.6,333.6,229.8,364.6,225.5,376.0,231.6,393.1,234.3,429.7,240.9,428.2,244.0,390.4,266.6,402.7,287.1,404.2,290.2,411.4,284.1,416.2,290.2,418.6,295.9,430.6,306.8,427.0,334.2,430.0,338.5,420.4,349.0,429.4,355.4,424.6,366.2,425.8,370.2,433.9,369.0,454.7,376.2,470.6,403.7,476.6,408.2,505.4,424.5,506.9,429.0,512.3,437.5,502.1,437.5,456.5,454.1,430.9,453.8,412.9,439.6,402.1,433.6,390.4,435.1,359.2,450.2,330.0,460.4,325.8,463.8,317.7,453.8,322.5,443.8,313.2,410.0,301.2,335.4,304.5,325.8,328.8,305.3,339.3,287.1,335.4,271.7,341.1,266.6,321.9],
        "Geita": [205.6,253.5,207.1,277.8,216.8,296.4,219.8,316.2,222.2,319.2,222.2,335.4,226.8,340.2,229.8,333.3,244.3,330.6,247.3,326.7,255.7,323.7,267.2,326.4,269.3,343.5,272.0,345.0,285.6,336.0,298.6,340.2,307.1,338.7,312.5,333.6,324.9,330.9,337.0,304.2,360.8,303.6,365.0,301.5,363.5,297.3,354.5,295.2,353.0,287.1,339.7,283.2,305.6,285.6,301.0,282.0,298.9,286.2,293.2,289.5,281.7,288.0,276.0,281.4,274.5,274.5,265.7,274.2,262.1,271.5,261.8,259.8,251.8,260.1,229.2,253.5,228.0,233.6,216.2,251.7],
        "Tabora": [222.8,376.6,204.7,401.2,204.7,433.0,190.5,446.8,203.2,463.4,246.7,465.8,254.5,459.8,276.0,461.9,286.8,493.4,316.7,518.6,328.5,521.0,330.9,569.1,347.2,569.4,360.2,560.1,397.6,564.0,409.7,544.4,400.7,540.5,401.0,535.1,424.2,517.7,428.1,506.6,409.4,506.3,404.9,476.3,386.8,474.8,377.1,468.5,370.5,453.5,370.2,427.6,346.9,424.0,343.3,418.9,330.3,425.8,306.5,422.5,302.5,430.0,296.5,430.6,288.9,403.9,264.2,401.5,252.1,395.5,248.8,388.9,241.2,389.8,241.5,413.5,234.6,417.7,231.0,413.8,231.0,391.9],
        "Kigoma": [177.5,454.4,180.3,458.3,180.3,473.9,176.0,484.1,176.6,504.8,190.2,518.3,212.9,518.9,219.5,521.9,257.5,519.2,260.9,522.8,260.3,530.6,255.1,533.3,245.5,533.3,237.6,538.1,237.3,547.1,248.5,545.6,252.4,540.8,301.9,540.5,305.9,547.1,313.1,549.8,314.0,562.5,324.0,564.9,327.3,568.2,330.9,546.2,330.9,530.0,327.6,519.5,316.7,518.6,306.2,509.9,304.0,504.2,298.6,503.6,289.3,495.8,284.4,489.2,277.2,461.9,253.9,460.4,247.3,465.5,228.0,466.7,205.3,464.0,198.7,454.7,193.8,459.5,187.2,460.1],
        "Rukwa": [241.5,620.4,240.9,634.5,234.3,636.9,233.7,644.4,212.6,663.7,202.9,664.3,202.9,672.1,199.0,676.9,200.2,682.0,196.0,684.7,202.0,692.2,202.0,700.3,204.4,706.6,230.1,715.0,234.6,720.7,234.9,727.3,245.8,734.5,261.5,734.2,264.5,736.9,264.8,743.8,277.8,743.2,276.0,717.7,279.0,715.0,284.4,716.2,289.3,710.8,294.7,700.0,292.6,686.2,296.2,682.3,303.4,680.8,309.5,674.2,310.7,663.4,301.3,660.7,291.4,649.8,287.1,649.5,277.2,654.1,265.4,650.8,263.3,648.0,263.3,637.5,251.2,629.4,253.6,622.2],
        "Katavi": [329.7,550.2,328.8,560.7,324.3,563.7,314.0,560.4,313.1,549.2,306.8,546.8,304.3,541.1,250.0,541.4,241.5,546.2,234.9,538.7,223.4,538.7,221.3,544.4,211.7,542.9,206.8,548.0,193.5,543.2,193.8,549.2,189.3,552.9,189.9,566.4,179.6,576.3,173.9,574.2,172.1,562.8,167.0,562.5,166.7,588.6,160.0,620.1,170.6,633.3,172.1,643.2,186.9,666.7,189.0,678.7,194.7,684.1,200.5,684.1,204.1,664.0,213.8,663.4,229.8,647.7,240.6,647.4,243.1,620.7,274.5,621.3,278.7,611.1,289.6,604.5,294.1,589.2,317.9,579.9,322.2,570.6,346.6,570.0,330.6,567.6],
        "Singida": [511.8,300.9,482.5,301.8,469.8,307.2,463.5,322.8,452.6,326.7,435.7,358.3,433.9,391.0,439.9,402.7,452.9,411.7,454.4,430.0,449.3,440.8,438.7,444.1,437.5,501.5,423.3,518.9,396.7,539.6,404.3,544.7,405.5,551.4,398.2,565.2,410.0,567.9,420.0,576.6,436.3,612.3,444.7,606.9,456.5,606.9,490.3,583.5,492.5,573.0,515.4,558.3,529.6,560.7,530.2,546.5,545.3,522.2,539.3,497.6,542.0,469.4,549.5,451.1,535.9,433.6,534.7,415.9,537.1,407.5,549.8,402.4,549.5,384.7,536.8,373.9,535.9,364.3,528.1,362.5,522.6,351.1,512.1,346.8,519.6,318.3,528.4,309.0],
        "Dodoma": [629.5,329.1,603.0,338.7,593.6,337.5,592.4,344.1,580.3,350.8,576.4,365.2,565.2,380.2,544.4,380.2,549.2,384.1,550.7,397.6,538.0,403.0,535.0,434.2,549.5,451.4,542.6,469.1,539.9,497.6,545.6,521.9,530.8,545.9,529.0,559.8,522.6,563.7,530.5,564.0,533.8,569.1,546.5,561.9,558.6,561.9,565.5,566.1,566.4,572.1,580.0,579.3,621.7,579.3,630.1,592.2,647.6,599.1,651.6,594.9,650.1,580.8,662.1,569.7,660.0,548.6,664.9,535.1,676.6,520.1,676.3,491.3,691.1,480.8,690.2,477.2,668.8,474.2,630.1,439.3,632.5,425.5,626.5,418.9,626.5,400.9,630.4,397.3,635.6,364.6],
        "Manyara": [493.7,285.6,491.5,300.9,512.7,300.6,525.7,307.5,512.1,348.3,534.7,365.5,543.8,379.6,564.3,381.7,583.6,347.1,590.3,347.1,596.6,338.4,624.7,329.4,631.9,331.5,636.2,369.4,629.2,382.9,625.9,421.0,632.9,424.9,631.3,441.1,667.6,473.6,694.7,476.9,703.5,467.9,703.8,454.4,724.3,404.5,756.3,398.5,769.0,389.8,765.1,361.6,754.2,362.8,735.5,351.1,736.7,335.1,727.4,316.2,726.4,293.1,710.4,267.3,695.7,261.0,690.2,248.0,677.2,258.9,663.3,256.2,636.5,280.8,606.6,279.9,605.1,255.6,597.5,249.8,583.9,250.8,580.9,264.6,591.2,268.5,584.5,290.1,577.0,286.2,576.7,269.1,570.7,276.3,550.7,274.2,543.2,269.4,541.1,260.4,531.4,261.6,511.2,282.6],
        "Arusha": [478.6,176.6,479.8,181.4,534.1,182.9,537.1,185.6,531.7,221.9,525.4,224.3,519.3,216.8,514.8,217.1,514.8,279.3,530.8,261.6,539.6,259.8,543.5,273.3,563.1,273.9,580.0,291.3,588.8,284.4,590.0,260.4,593.0,257.7,605.1,264.9,605.1,279.9,637.1,280.2,660.9,257.7,679.0,258.3,687.8,254.1,689.6,247.1,683.9,243.5,683.9,218.3,694.7,215.3,706.5,205.7,613.8,152.9,606.9,143.5,595.7,141.7,549.8,115.9,542.6,119.5,542.0,157.7,536.8,179.9,487.0,180.5],
        "Kilimanjaro": [702.3,207.5,696.9,210.8,694.7,215.3,684.5,216.5,684.5,243.8,693.8,251.1,696.6,261.9,702.9,262.8,711.1,267.9,727.1,294.0,727.4,328.5,731.9,329.4,736.4,336.0,735.8,351.7,753.0,362.5,762.7,361.3,767.8,367.6,769.0,385.6,769.6,364.0,782.0,360.7,788.3,348.6,811.0,321.0,762.1,286.2,753.3,277.2,750.9,268.2,741.5,265.8,740.9,255.0,746.7,243.8,744.9,227.6,717.1,210.8],
        "Tanga": [872.3,364.0,867.5,363.1,809.8,321.6,782.3,360.1,769.6,362.5,769.6,388.9,767.5,391.9,724.9,403.6,713.5,424.3,711.4,444.1,704.4,453.8,704.1,467.3,690.8,476.3,686.9,482.3,710.1,484.1,723.4,479.9,729.2,471.8,779.9,470.9,785.6,474.5,796.8,475.1,810.7,470.6,832.7,475.4,837.3,479.6,840.3,478.4,845.7,453.5,851.8,449.5,854.5,441.4,853.9,432.1,857.5,427.0,859.6,413.2,866.2,402.4,867.5,388.6,872.0,385.0],
        "Morogoro": [756.0,474.8,726.8,471.2,718.6,482.3,685.7,483.2,677.2,489.5,677.2,520.1,669.1,524.9,660.6,547.1,662.7,569.7,652.8,579.0,649.5,605.1,667.0,621.0,687.2,626.7,675.7,648.9,638.6,650.8,624.7,668.8,610.2,673.9,576.4,715.6,549.2,717.4,558.0,749.5,578.5,764.6,577.3,772.4,583.0,774.5,591.8,767.6,598.4,770.9,596.9,786.5,579.7,808.1,587.6,821.3,596.6,820.1,614.1,798.8,637.7,793.1,644.3,801.5,642.5,824.9,651.6,824.9,699.0,795.2,720.7,748.0,713.2,729.7,719.5,695.5,754.5,652.9,768.4,620.7,800.7,621.9,802.2,595.2,814.9,589.2,820.0,575.4,804.6,573.6,804.6,550.5,772.9,532.7,772.6,503.6,758.5,492.2],
        "Pwani": [842.1,513.8,840.3,513.8,839.4,526.4,827.3,540.2,797.4,543.5,802.8,551.7,803.1,572.1,815.5,574.2,818.8,577.8,817.6,586.5,802.8,593.7,800.7,620.4,796.5,622.8,782.6,620.1,766.6,621.0,757.5,644.4,758.8,648.6,768.1,653.8,771.1,660.4,817.0,684.4,819.7,690.1,826.1,694.0,840.6,683.5,863.8,681.4,875.3,676.9,883.5,677.8,886.5,665.8,890.4,661.6,889.8,641.1,880.7,630.3,878.6,622.2,883.5,605.4,881.6,595.5,871.4,581.7,872.9,565.8,865.0,559.2,862.9,539.0,868.1,533.6,848.1,522.8],
        "Dar es Salaam": [738.8,472.4,749.4,475.4,754.5,475.4,757.2,477.5,758.8,492.2,768.1,503.6,771.1,504.2,772.9,506.3,773.6,533.3,780.2,538.4,789.3,538.7,798.3,544.1,808.0,543.2,812.2,540.5,826.7,540.2,837.3,529.7,840.0,522.5,839.7,515.0,841.2,513.2,840.6,491.9,835.7,488.3,836.7,478.4,834.8,476.0,827.6,475.7,819.7,472.4,805.6,471.2,793.8,475.4,785.6,475.1,782.0,471.5],
        "Mbeya": [319.7,571.2,315.5,581.7,292.9,587.4,289.9,604.8,279.0,610.8,274.2,620.7,250.9,624.3,253.6,632.1,263.6,637.5,264.8,650.2,277.2,653.5,291.1,649.5,310.4,669.7,303.4,680.8,293.2,685.9,294.4,701.5,285.0,714.4,276.6,716.2,277.2,740.2,270.8,743.8,266.0,734.8,266.6,746.2,305.6,753.8,316.4,766.1,329.7,766.4,363.5,784.4,380.1,784.7,391.0,795.2,419.4,793.4,430.0,800.6,433.9,784.7,442.9,777.5,422.4,734.8,477.4,722.5,490.0,705.4,490.3,690.4,511.8,674.8,521.1,647.7,512.1,645.6,492.8,629.1,463.8,626.1,452.6,617.7,450.8,608.1,435.1,609.6,417.9,573.9,397.0,563.1,359.3,560.7,345.4,570.6],
        "Njombe": [506.3,678.1,490.9,689.8,490.6,705.1,477.1,722.5,462.3,728.2,438.4,728.5,435.1,732.7,420.9,733.3,421.2,739.9,428.1,744.7,449.3,791.0,458.3,796.1,481.6,828.5,484.0,847.4,487.9,853.2,487.6,863.1,484.9,866.7,486.7,875.1,502.1,870.0,510.0,861.3,519.6,856.8,523.2,844.7,533.8,840.8,543.5,818.0,536.5,811.1,536.5,806.0,571.6,776.0,582.4,774.5,577.6,763.4,557.4,747.4,551.0,733.3,548.9,713.8,554.6,709.3,548.6,706.0,546.8,697.3,540.2,691.6,533.8,694.0,527.2,688.9,507.9,688.3,504.8,685.6],
        "Iringa": [444.7,607.5,449.3,608.1,454.4,619.8,459.8,620.4,464.1,626.1,491.2,628.8,505.1,637.5,508.5,644.4,520.5,648.6,520.2,657.7,503.9,682.6,504.2,697.0,509.1,688.6,514.8,687.7,521.7,697.0,529.0,693.7,545.0,697.3,549.2,709.0,545.3,715.6,546.5,722.2,553.1,714.4,569.1,714.1,579.7,718.3,580.3,705.4,607.5,680.5,610.8,673.3,627.7,666.1,638.6,650.5,674.5,651.1,680.9,636.9,692.6,630.0,677.5,621.3,667.6,620.7,664.9,609.3,656.7,611.7,650.4,606.0,653.4,577.2,650.7,578.7,651.0,595.2,646.1,598.2,629.5,591.6,622.9,579.9,580.6,579.9,561.9,563.4,545.9,562.5,537.7,566.4,532.9,559.5,507.5,561.6,491.2,575.1,491.5,582.3,477.1,594.6,460.4,600.3,457.1,606.3],
        "Ruvuma": [490.0,874.2,494.3,884.7,491.5,922.2,514.8,944.1,523.2,962.5,571.3,965.8,597.2,949.5,619.6,961.9,621.4,974.8,663.0,975.4,673.9,960.4,726.8,973.3,754.8,962.5,761.2,939.0,784.4,936.9,776.6,893.4,759.7,875.1,748.2,874.2,678.4,841.4,680.3,819.8,696.3,800.6,644.0,825.5,639.5,822.5,644.0,802.1,635.0,791.9,616.5,797.0,597.5,819.8,583.9,818.9,580.0,809.3,596.3,787.1,596.3,764.6,571.6,776.3,537.1,805.4,543.5,821.3,536.2,836.9,522.0,844.7,517.8,858.6],
        "Lindi": [757.2,646.2,718.6,697.9,719.8,710.5,713.8,730.6,721.3,747.4,709.8,764.6,709.8,775.7,701.4,792.2,686.3,800.6,690.2,807.8,680.9,818.3,676.6,841.7,714.1,855.3,747.0,873.6,759.4,874.8,777.5,894.6,779.6,918.3,779.9,898.5,793.8,894.0,801.3,882.3,844.5,873.3,870.8,860.1,895.2,855.6,900.4,859.8,902.2,873.9,913.3,876.3,914.3,860.4,920.3,857.7,923.3,848.6,917.0,842.0,923.0,821.6,912.7,804.2,908.2,757.7,896.4,750.5,893.4,727.3,883.8,717.1,879.5,677.5,837.3,684.4,823.1,692.2,818.2,684.7,772.0,661.6,765.7,650.5],
        "Mtwara": [780.2,897.3,780.2,919.5,783.8,924.3,782.6,937.5,790.8,939.3,809.8,948.6,814.9,946.8,831.5,934.8,837.9,933.6,839.7,931.5,847.5,928.8,859.6,927.0,869.6,927.0,873.8,929.1,877.4,928.2,884.1,921.6,895.5,914.1,904.6,912.0,890.4,912.3,876.5,902.7,872.9,897.3,862.9,897.6,864.1,903.6,859.6,906.6,854.2,904.2,853.3,900.0,846.3,901.8,842.4,897.6,839.4,897.0,829.7,901.5,825.2,901.5,822.5,899.4,820.4,894.3,814.6,891.0,811.3,883.2,800.4,882.3,795.6,888.3,793.5,894.3],
    })

    property var lakeVictoria:    [440.8,58.9,424.5,55.3,263.6,55.9,261.5,80.8,243.4,136.3,249.1,143.5,242.8,168.8,251.2,165.8,255.7,175.1,250.0,186.2,262.7,191.9,268.4,188.9,271.1,180.5,279.3,180.2,274.8,176.9,276.6,171.2,283.5,170.9,289.9,161.9,298.3,162.5,304.0,173.9,321.0,181.7,324.6,174.2,342.4,181.1,348.1,171.8,360.5,170.6,369.3,180.5,389.5,184.1,398.2,169.7,421.5,158.3,420.6,150.2,405.5,156.2,387.4,155.9,372.3,150.5,371.1,143.5,385.9,136.6,377.4,134.2,383.8,120.7,394.0,124.9,399.8,121.3,399.5,111.1,409.1,109.6,409.7,95.5,417.6,92.8,424.8,73.6]
    property var lakeTanganyika:  [64.6,439.3,62.2,445.6,54.0,446.5,51.3,467.3,39.9,476.3,40.2,489.2,49.5,499.1,59.8,525.8,65.2,528.8,65.5,544.4,84.5,564.9,87.9,573.3,102.7,576.6,119.9,594.3,125.0,609.9,124.4,628.8,129.2,633.3,130.7,642.6,145.8,654.1,155.5,670.3,163.3,671.8,167.0,668.2,162.1,653.5,141.6,621.3,140.1,606.9,130.7,583.8,115.3,562.2,81.2,537.5,76.7,524.3,64.9,508.1,61.6,480.5,73.7,459.8]

    property var regionColors: ({
        "Kagera": "#87c874",
        "Mwanza": "#fff93f",
        "Mara": "#aca6d6",
        "Simiyu": "#d8e860",
        "Shinyanga": "#d0e45e",
        "Geita": "#fff93f",
        "Tabora": "#ffd3ee",
        "Kigoma": "#e3b083",
        "Rukwa": "#ffd3ee",
        "Katavi": "#86d7f2",
        "Singida": "#c0e393",
        "Dodoma": "#cfcd76",
        "Manyara": "#d8cdef",
        "Arusha": "#d8cdef",
        "Kilimanjaro": "#cda8d4",
        "Tanga": "#a5d75e",
        "Morogoro": "#ffd3ec",
        "Pwani": "#bee0fc",
        "Dar es Salaam": "#bfe1e3",
        "Mbeya": "#cfcd76",
        "Njombe": "#88c975",
        "Iringa": "#88c975",
        "Ruvuma": "#e5fafd",
        "Lindi": "#fea376",
        "Mtwara": "#fde024",
    })

    property var regionInfo: ({
        "Kagera": {capital:"Bukoba", area:"28,388 km²", attractions:"Ziwa Viktoria, Misitu ya Kagera, Rubondo Island NP, Makao ya TANU Bukoba"},
        "Mwanza": {capital:"Mwanza", area:"9,467 km²", attractions:"Ziwa Viktoria, Bismarck Rock, Saa Nane Island NP, Bwiru Palace"},
        "Mara": {capital:"Musoma", area:"21,760 km²", attractions:"Serengeti NP (Kaskazini), Ziwa Viktoria, Mugumu Cultural Centre"},
        "Simiyu": {capital:"Bariadi", area:"24,575 km²", attractions:"Serengeti NP (Mipaka), Mto Mara, Utamaduni wa Wasukuma"},
        "Shinyanga": {capital:"Shinyanga", area:"18,914 km²", attractions:"Mgodi wa Dhahabu Williamson, Ziwa Mwadui, Utamaduni Wasukuma"},
        "Geita": {capital:"Geita", area:"20,054 km²", attractions:"Mgodi Mkubwa wa Dhahabu GGML, Ziwa Viktoria, Msitu wa Buyagu"},
        "Tabora": {capital:"Tabora", area:"76,151 km²", attractions:"Nyumba ya Livingstone, Makao ya Mirambo, Tembo Msitu wa Ugalla"},
        "Kigoma": {capital:"Kigoma", area:"45,066 km²", attractions:"Gombe Stream NP (Sokwe), Mahale Mountains NP, Ziwa Tanganyika, Ujiji"},
        "Rukwa": {capital:"Sumbawanga", area:"22,825 km²", attractions:"Ziwa Rukwa, Milima ya Ufipa, Msitu wa Lwafi, Ndege Wengi"},
        "Katavi": {capital:"Mpanda", area:"45,840 km²", attractions:"Katavi NP (Tembo & Viboko Wengi), Ziwa Katavi, Ziwa Chada"},
        "Singida": {capital:"Singida", area:"49,341 km²", attractions:"Ziwa Singida, Ziwa Kindai, Milima ya Bereko, Nyumba za Kale Wanyaturu"},
        "Dodoma": {capital:"Dodoma", area:"41,311 km²", attractions:"Bunge la Tanzania, Bustani ya Helu, Mlima wa Dodoma, Shamba la Zabibu"},
        "Manyara": {capital:"Babati", area:"44,522 km²", attractions:"Tarangire NP, Ziwa Manyara NP, Bonde la Ufa, Mlima Hanang"},
        "Arusha": {capital:"Arusha", area:"37,576 km²", attractions:"Ngorongoro Crater, Serengeti NP, Olduvai Gorge, Longido, Mt Meru"},
        "Kilimanjaro": {capital:"Moshi", area:"13,250 km²", attractions:"Mlima Kilimanjaro (5,895m), Chagga Caves, Marangu, Mandhari ya Kahawa"},
        "Tanga": {capital:"Tanga", area:"26,808 km²", attractions:"Mapango ya Amboni, Tongoni Ruins, Toten Island, Misitu ya Amani"},
        "Morogoro": {capital:"Morogoro", area:"70,799 km²", attractions:"Udzungwa Mountains NP, Mikumi NP, Bwawa la Mtera, Uluguru Mountains"},
        "Pwani": {capital:"Kibaha", area:"32,407 km²", attractions:"Saadani NP, Kisiwa cha Mafia, Mikoko ya Rufiji, Ufukwe wa Bahari"},
        "Dar es Salaam": {capital:"Dar es Salaam", area:"1,393 km²", attractions:"Kisiwa cha Bongoyo, Msasani Beach, National Museum, Village Museum"},
        "Mbeya": {capital:"Mbeya", area:"60,350 km²", attractions:"Kitulo NP (Bustani ya Mungu), Msitu wa Poroto, Ziwa Ngozi, Daraja la Mungu"},
        "Njombe": {capital:"Njombe", area:"21,347 km²", attractions:"Maporomoko ya Kihansi, Misitu ya Udzungwa, Uzalishaji wa Chai, Mlima Rungwe"},
        "Iringa": {capital:"Iringa", area:"35,743 km²", attractions:"Ruaha NP (Kubwa Zaidi TZ), Isimila Stone Age Site, Bwawa la Mtera"},
        "Ruvuma": {capital:"Songea", area:"63,669 km²", attractions:"Selous GR (Kusini), Mbamba Bay, Ziwa Nyasa, Makaburi ya Wangoni"},
        "Lindi": {capital:"Lindi", area:"66,046 km²", attractions:"Msitu wa Litipo, Mikindani Old Town, Ufukwe wa Mnazi Bay, Dinosaur Fossils"},
        "Mtwara": {capital:"Mtwara", area:"16,707 km²", attractions:"Mnazi Bay-Ruvuma Marine Park, Mikindani Fort, Ufukwe wa Msimbati"},
    })

    // ── Build SVG path string from flat array ──────────────────────────
    function buildPath(arr) {
        if (!arr || arr.length < 4) return ""
        var s = "M " + (arr[0]*sx).toFixed(1) + "," + (arr[1]*sy).toFixed(1)
        for (var i = 2; i < arr.length; i += 2)
            s += " L " + (arr[i]*sx).toFixed(1) + "," + (arr[i+1]*sy).toFixed(1)
        return s + " Z"
    }

    // ── Point-in-polygon (ray casting) ────────────────────────────────
    // px,py in 0–1000 space; arr is flat coordinate array in 0–1000 space
    function pointInPoly(px, py, arr) {
        var n = arr.length / 2
        var inside = false
        var j = n - 1
        for (var i = 0; i < n; i++) {
            var xi = arr[i*2],   yi = arr[i*2+1]
            var xj = arr[j*2],   yj = arr[j*2+1]
            if (((yi > py) !== (yj > py)) &&
                (px < (xj - xi) * (py - yi) / (yj - yi) + xi))
                inside = !inside
            j = i
        }
        return inside
    }

    // ── Centroid of flat array ─────────────────────────────────────────
    function centroid(arr) {
        var n = arr.length / 2
        var tx = 0, ty = 0
        for (var i = 0; i < n; i++) { tx += arr[i*2]; ty += arr[i*2+1] }
        return Qt.point(tx/n * sx, ty/n * sy)
    }

    // ── Hit test: find which region contains map-space point ──────────
    function hitRegion(mx, my) {
        // mx,my are pixel coords inside mapArea → convert to 0-1000 space
        var px = mx / sx
        var py = my / sy
        var names = Object.keys(regionData)
        for (var i = 0; i < names.length; i++) {
            if (pointInPoly(px, py, regionData[names[i]]))
                return names[i]
        }
        // Fallback: nearest centroid
        var best = "", bestD = 1e9
        for (var i = 0; i < names.length; i++) {
            var arr = regionData[names[i]]
            var n2 = arr.length / 2
            var cx = 0, cy2 = 0
            for (var k = 0; k < n2; k++) { cx += arr[k*2]; cy2 += arr[k*2+1] }
            cx /= n2; cy2 /= n2
            var dx = px-cx, dy = py-cy2, d = dx*dx+dy*dy
            if (d < bestD) { bestD = d; best = names[i] }
        }
        return best
    }

    // ── HEADER ────────────────────────────────────────────────────────
    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 58; color: "#040810"
        Text {
            anchors.centerIn: parent
            text: "🗺  RAMANI YA MIKOA 25 — TANZANIA"
            font.pixelSize: 19; font.bold: true; font.letterSpacing: 3; color: "#00e5ff"
        }
        Rectangle {
            anchors.bottom: parent.bottom; width: parent.width; height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.3; color: "#00e5ff" }
                GradientStop { position: 0.7; color: "#80f0ff" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // ── MAP AREA ──────────────────────────────────────────────────────
    Item {
        id: mapArea
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: infoPanel.top }
        clip: true

        // Ocean/water background
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1e4d7a" }
                GradientStop { position: 1.0; color: "#162e4a" }
            }
        }

        // ── Lake Victoria ─────────────────────────────────────────────
        Shape {
            anchors.fill: parent
            vendorExtensionsEnabled: false
            ShapePath {
                fillColor: "#5ab4d8"; strokeColor: "#2a6a90"; strokeWidth: 1.2
                PathSvg { path: root.buildPath(root.lakeVictoria) }
            }
        }
        Text {
            property point c: root.centroid(root.lakeVictoria)
            x: c.x - width/2; y: c.y - height/2
            text: "Ziwa Victoria"; font.pixelSize: 9; font.bold: true
            color: "#1a3a5a"
        }

        // ── Lake Tanganyika ───────────────────────────────────────────
        Shape {
            anchors.fill: parent
            vendorExtensionsEnabled: false
            ShapePath {
                fillColor: "#5ab4d8"; strokeColor: "#2a6a90"; strokeWidth: 1.2
                PathSvg { path: root.buildPath(root.lakeTanganyika) }
            }
        }
        Text {
            property point c: root.centroid(root.lakeTanganyika)
            x: c.x - width/2; y: c.y - height/2
            text: "Ziwa\nTanganyika"; font.pixelSize: 7; font.italic: true
            color: "#1a3a5a"; horizontalAlignment: Text.AlignHCenter
        }

        // ── Neighbour labels ──────────────────────────────────────────
        Repeater {
            model: [
                {t:"UGANDA",   x:48, y:10},  {t:"KENYA",     x:712,y:45},
                {t:"RWANDA",   x:5,  y:90},  {t:"BURUNDI",   x:0,  y:185},
                {t:"DR CONGO", x:0,  y:372}, {t:"ZAMBIA",    x:55, y:742},
                {t:"MALAWI",   x:228,y:788}, {t:"MOZAMBIQUE",x:482,y:820},
                {t:"INDIAN",   x:742,y:320}, {t:"OCEAN",     x:748,y:555},
            ]
            delegate: Text {
                x: modelData.x * root.sx; y: modelData.y * root.sy
                text: modelData.t; font.pixelSize: 8; font.italic: true
                color: "#4488aa"; opacity: 0.75
            }
        }

        // ── Region shapes ─────────────────────────────────────────────
        Repeater {
            model: Object.keys(root.regionData)
            delegate: Shape {
                anchors.fill: parent
                vendorExtensionsEnabled: false
                property string rname: modelData
                ShapePath {
                    fillColor: {
                        var b = root.regionColors[rname] || "#aaa"
                        if (root.selectedRegion === rname) return Qt.lighter(b, 1.45)
                        if (root.hoveredRegion  === rname) return Qt.lighter(b, 1.18)
                        return b
                    }
                    strokeColor: root.selectedRegion === rname ? "#ffffff" : "#1a1830"
                    strokeWidth: root.selectedRegion === rname ? 2.5 : 0.8
                    PathSvg { path: root.buildPath(root.regionData[rname]) }
                }
            }
        }

        // ── Region name labels ────────────────────────────────────────
        Repeater {
            model: Object.keys(root.regionData)
            delegate: Text {
                property var arr: root.regionData[modelData]
                property point c: root.centroid(arr)
                x: c.x - width/2; y: c.y - height/2
                text: modelData === "Dar es Salaam" ? "DSM" :
                      modelData === "Kilimanjaro"   ? "Kilim." : modelData
                font.pixelSize: 9; font.bold: true
                color: "#0e0e22"; opacity: 0.88
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // ── Selection glow ────────────────────────────────────────────
        Shape {
            anchors.fill: parent
            vendorExtensionsEnabled: false
            visible: root.selectedRegion !== ""
            ShapePath {
                fillColor: "transparent"
                strokeColor: "#00e5ff"; strokeWidth: 3.5
                PathSvg { path: root.buildPath(root.regionData[root.selectedRegion] || []) }
            }
        }

        // ── Single MouseArea with proper hit-test ─────────────────────
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.hoveredRegion !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: function(mouse) {
                var hit = root.hitRegion(mouse.x, mouse.y)
                if (hit) {
                    root.selectedRegion = hit
                    root.selectedData   = root.regionInfo[hit] || {}
                }
            }

            onPositionChanged: function(mouse) {
                root.hoveredRegion = root.hitRegion(mouse.x, mouse.y)
            }

            onExited: root.hoveredRegion = ""
        }
    }

    // ── INFO PANEL ────────────────────────────────────────────────────
    Rectangle {
        id: infoPanel
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: root.selectedRegion !== "" ? 210 : 52
        color: "#040810"
        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.top: parent.top; width: parent.width; height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.3; color: "#00e5ff" }
                GradientStop { position: 0.7; color: "#80f0ff" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.selectedRegion === ""
            text: "👆  Gusa mkoa wowote kupata maelezo zaidi"
            font.pixelSize: 13; color: "#2a5a7a"
        }

        Item {
            anchors { fill: parent; margins: 16 }
            visible: root.selectedRegion !== ""
            opacity: root.selectedRegion !== "" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Row {
                id: titleRow
                anchors { top: parent.top; left: parent.left }
                spacing: 12
                Rectangle {
                    width: 22; height: 22; radius: 5
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.regionColors[root.selectedRegion] || "#888"
                    border.color: "#00e5ff"; border.width: 1.5
                }
                Text {
                    text: root.selectedRegion
                    font.pixelSize: 22; font.bold: true; font.letterSpacing: 2
                    color: "#00e5ff"
                }
            }

            Rectangle {
                anchors { top: parent.top; right: parent.right }
                width: 28; height: 28; radius: 14
                color: "#111a28"; border.color: "#ef4444"; border.width: 1
                Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 14; color: "#ef4444" }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectedRegion = ""
                }
            }

            Rectangle {
                id: divider
                anchors { top: titleRow.bottom; topMargin: 8 }
                width: parent.width; height: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.1; color: "#1e4060" }
                    GradientStop { position: 0.9; color: "#1e4060" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            Column {
                anchors { top: divider.bottom; topMargin: 10; left: parent.left; right: parent.right }
                spacing: 8

                Row {
                    spacing: 24
                    Row {
                        spacing: 8
                        Text { text: "🏛  Mji Mkuu:"; font.pixelSize: 11; color: "#4a9abf" }
                        Text {
                            text: root.selectedData["capital"] || "—"
                            font.pixelSize: 12; font.bold: true; color: "#ddf0ff"
                        }
                    }
                    Row {
                        spacing: 8
                        Text { text: "📐  Eneo:"; font.pixelSize: 11; color: "#4a9abf" }
                        Text {
                            text: root.selectedData["area"] || "—"
                            font.pixelSize: 12; font.bold: true; color: "#ddf0ff"
                        }
                    }
                }

                Row {
                    spacing: 8
                    width: parent.width
                    Text { text: "🌍  Vivutio:"; font.pixelSize: 11; color: "#4a9abf"; topPadding: 2 }
                    Text {
                        text: root.selectedData["attractions"] || "—"
                        font.pixelSize: 12; font.bold: true; color: "#ddf0ff"
                        wrapMode: Text.WordWrap
                        width: parent.width - 90
                    }
                }
            }
        }
    }
}
