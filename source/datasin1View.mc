import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! 数据字段视图
//! 支持 Edge 码表设备，根据字段数量动态选择布局
class datasin1View extends WatchUi.DataField {
    // 数据变量
    hidden var mPower as Numeric; // 功率 (W)
    hidden var mSpeed as Numeric; // 速度 (km/h)
    hidden var mHeartRate as Numeric; // 心率 (bpm)
    hidden var mGrade as Numeric; // 坡度 (%)

    // 布局配置
    hidden var mIsLargeScreen as Boolean; // 大屏设备标志
    hidden var mFieldCount as Number; // 当前字段数量

    // 用户配置 - 布局顺序
    // 双字段: 0=上大下小, 1=上小下大
    // 三字段: 0=倒品字(上2小下1大), 1=正品字(上1大下2小)
    hidden var mLayoutConfig as Number;

    function initialize() {
        DataField.initialize();
        mPower = 0;
        mSpeed = 0.0f;
        mHeartRate = 0;
        mGrade = 0.0f;
        mIsLargeScreen = false;
        mFieldCount = 3; // 默认3字段
        mLayoutConfig = 0;
    }

    //! onLayout - 简化版本，不再处理手表遮挡
    function onLayout(dc as Dc) as Void {
        View.setLayout(Rez.Layouts.MainLayout(dc));
        var screenHeight = dc.getHeight();
        mIsLargeScreen = screenHeight > 200;
    }

    function compute(info as Activity.Info) as Void {
        // 功率 (watts)
        if (info has :currentPower) {
            mPower =
                info.currentPower != null ? info.currentPower as Number : 0;
        }
        // 速度 (m/s -> km/h)
        if (info has :currentSpeed) {
            mSpeed =
                info.currentSpeed != null
                    ? (info.currentSpeed as Float) * 3.6
                    : 0.0f;
        }
        // 心率 (bpm)
        if (info has :currentHeartRate) {
            mHeartRate =
                info.currentHeartRate != null
                    ? info.currentHeartRate as Number
                    : 0;
        }
        // 坡度 (%)
        if (info has :currentGrade) {
            mGrade =
                info.currentGrade != null
                    ? (info.currentGrade as Float) * 100.0
                    : 0.0f;
        }
    }

    //! 获取标签字体
    private function getLabelFont() {
        return mIsLargeScreen ? Graphics.FONT_MEDIUM : Graphics.FONT_TINY;
    }

    //! 获取数值字体
    private function getValueFont() {
        return mIsLargeScreen ? Graphics.FONT_LARGE : Graphics.FONT_MEDIUM;
    }

    //! 获取单位字体
    private function getUnitFont() {
        return Graphics.FONT_TINY;
    }

    //! 获取居中X坐标
    private function getCenterX(width as Number) as Number {
        return width / 2;
    }

    //! 绘制单字段居中布局
    private function drawLayout1(
        dc as Dc,
        data as Array,
        startY as Number,
        width as Number,
        height as Number
    ) as Void {
        var centerX = getCenterX(width);
        var centerY = startY + height / 2;

        var valueFont = getValueFont();
        var unitFont = getUnitFont();

        var valueText = data[0].get(:value);
        var unitText = data[0].get(:unit);

        var valueDims = dc.getTextDimensions(valueText, valueFont);
        var unitDims = dc.getTextDimensions(unitText, unitFont);

        // 数值垂直居中
        var valueY = centerY - valueDims[1] / 2;
        // 单位与数值底部对齐
        var unitY = centerY - unitDims[1] / 2;
        // 单位在数值右边
        var totalWidth = valueDims[0] + 4 + unitDims[0];
        var startOffsetX = centerX - totalWidth / 2;

        // 绘制数值
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            startOffsetX + valueDims[0] / 2,
            valueY,
            valueFont,
            valueText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        // 绘制单位
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            startOffsetX + valueDims[0] + 4 + unitDims[0] / 2,
            unitY,
            unitFont,
            unitText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    //! 绘制双字段上下布局
    private function drawLayout2(
        dc as Dc,
        data as Array,
        startY as Number,
        width as Number,
        height as Number
    ) as Void {
        var centerX = getCenterX(width);
        var halfHeight = height / 2;
        var unitFont = getUnitFont();

        var bigFont = getValueFont();

        var isReversed = mLayoutConfig == 1;

        var topData = isReversed ? data[1] : data[0];
        var bottomData = isReversed ? data[0] : data[1];

        // 上半部分
        var topCenterY = startY + halfHeight / 2;
        var topValueDims = dc.getTextDimensions(topData.get(:value), bigFont);
        var topUnitDims = dc.getTextDimensions(topData.get(:unit), unitFont);
        var topTotalWidth = topValueDims[0] + 4 + topUnitDims[0];
        var topStartX = centerX - topTotalWidth / 2;
        var topValueY = topCenterY - topValueDims[1] / 2;
        var topUnitY = topCenterY - topUnitDims[1] / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(topStartX + topValueDims[0] / 2, topValueY, bigFont, topData.get(:value), Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(topStartX + topValueDims[0] + 4 + topUnitDims[0] / 2, topUnitY, unitFont, topData.get(:unit), Graphics.TEXT_JUSTIFY_CENTER);

        // 下半部分
        var bottomCenterY = startY + halfHeight + halfHeight / 2;
        var bottomValueDims = dc.getTextDimensions(bottomData.get(:value), bigFont);
        var bottomUnitDims = dc.getTextDimensions(bottomData.get(:unit), unitFont);
        var bottomTotalWidth = bottomValueDims[0] + 4 + bottomUnitDims[0];
        var bottomStartX = centerX - bottomTotalWidth / 2;
        var bottomValueY = bottomCenterY - bottomValueDims[1] / 2;
        var bottomUnitY = bottomCenterY - bottomUnitDims[1] / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(bottomStartX + bottomValueDims[0] / 2, bottomValueY, bigFont, bottomData.get(:value), Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(bottomStartX + bottomValueDims[0] + 4 + bottomUnitDims[0] / 2, bottomUnitY, unitFont, bottomData.get(:unit), Graphics.TEXT_JUSTIFY_CENTER);
    }

    //! 绘制三字段品字布局
    private function drawLayout3(
        dc as Dc,
        data as Array,
        startY as Number,
        width as Number,
        height as Number
    ) as Void {
        var labelFont = getLabelFont();
        var valueFont = getValueFont();
        var unitFont = getUnitFont();
        var centerX = getCenterX(width);

        var halfWidth = width / 2;
        var halfHeight = height / 2;

        var isReversed = mLayoutConfig == 1;

        if (!isReversed) {
            // 倒品字：上2小，下1大
            // 左上
            var topY = startY + halfHeight * 0.3;
            var leftCenterX = halfWidth / 2;
            var leftData = data[0];

            var leftValueDims = dc.getTextDimensions(leftData.get(:value), labelFont);
            var leftUnitDims = dc.getTextDimensions(leftData.get(:unit), unitFont);
            var leftTotalWidth = leftValueDims[0] + 4 + leftUnitDims[0];
            var leftStartX = leftCenterX - leftTotalWidth / 2;
            var leftValueY = topY - leftValueDims[1] / 2;
            var leftUnitY = topY - leftUnitDims[1] / 2;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(leftStartX + leftValueDims[0] / 2, leftValueY, labelFont, leftData.get(:value), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(leftStartX + leftValueDims[0] + 4 + leftUnitDims[0] / 2, leftUnitY, unitFont, leftData.get(:unit), Graphics.TEXT_JUSTIFY_CENTER);

            // 右上
            var rightCenterX = halfWidth + halfWidth / 2;
            var rightData = data[1];

            var rightValueDims = dc.getTextDimensions(rightData.get(:value), labelFont);
            var rightUnitDims = dc.getTextDimensions(rightData.get(:unit), unitFont);
            var rightTotalWidth = rightValueDims[0] + 4 + rightUnitDims[0];
            var rightStartX = rightCenterX - rightTotalWidth / 2;
            var rightValueY = topY - rightValueDims[1] / 2;
            var rightUnitY = topY - rightUnitDims[1] / 2;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(rightStartX + rightValueDims[0] / 2, rightValueY, labelFont, rightData.get(:value), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(rightStartX + rightValueDims[0] + 4 + rightUnitDims[0] / 2, rightUnitY, unitFont, rightData.get(:unit), Graphics.TEXT_JUSTIFY_CENTER);

            // 下大半
            var bottomCenterY = startY + halfHeight + halfHeight * 0.4;
            var bottomData = data[2];

            var bottomValueDims = dc.getTextDimensions(bottomData.get(:value), valueFont);
            var bottomUnitDims = dc.getTextDimensions(bottomData.get(:unit), unitFont);
            var bottomTotalWidth = bottomValueDims[0] + 4 + bottomUnitDims[0];
            var bottomStartX = centerX - bottomTotalWidth / 2;
            var bottomValueY = bottomCenterY - bottomValueDims[1] / 2;
            var bottomUnitY = bottomCenterY - bottomUnitDims[1] / 2;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(bottomStartX + bottomValueDims[0] / 2, bottomValueY, valueFont, bottomData.get(:value), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(bottomStartX + bottomValueDims[0] + 4 + bottomUnitDims[0] / 2, bottomUnitY, unitFont, bottomData.get(:unit), Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            // 正品字：上1大，下2小
            // 上大半
            var topCenterY = startY + halfHeight * 0.35;
            var topData = data[0];

            var topValueDims = dc.getTextDimensions(topData.get(:value), valueFont);
            var topUnitDims = dc.getTextDimensions(topData.get(:unit), unitFont);
            var topTotalWidth = topValueDims[0] + 4 + topUnitDims[0];
            var topStartX = centerX - topTotalWidth / 2;
            var topValueY = topCenterY - topValueDims[1] / 2;
            var topUnitY = topCenterY - topUnitDims[1] / 2;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(topStartX + topValueDims[0] / 2, topValueY, valueFont, topData.get(:value), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(topStartX + topValueDims[0] + 4 + topUnitDims[0] / 2, topUnitY, unitFont, topData.get(:unit), Graphics.TEXT_JUSTIFY_CENTER);

            // 左下小
            var bottomY = startY + halfHeight + halfHeight * 0.4;
            var leftData = data[1];

            var leftValueDims = dc.getTextDimensions(leftData.get(:value), labelFont);
            var leftUnitDims = dc.getTextDimensions(leftData.get(:unit), unitFont);
            var leftTotalWidth = leftValueDims[0] + 4 + leftUnitDims[0];
            var leftStartX = halfWidth / 2 - leftTotalWidth / 2;
            var leftValueY = bottomY - leftValueDims[1] / 2;
            var leftUnitY = bottomY - leftUnitDims[1] / 2;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(leftStartX + leftValueDims[0] / 2, leftValueY, labelFont, leftData.get(:value), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(leftStartX + leftValueDims[0] + 4 + leftUnitDims[0] / 2, leftUnitY, unitFont, leftData.get(:unit), Graphics.TEXT_JUSTIFY_CENTER);

            // 右下小
            var rightData = data[2];

            var rightValueDims = dc.getTextDimensions(rightData.get(:value), labelFont);
            var rightUnitDims = dc.getTextDimensions(rightData.get(:unit), unitFont);
            var rightTotalWidth = rightValueDims[0] + 4 + rightUnitDims[0];
            var rightStartX = halfWidth + halfWidth / 2 - rightTotalWidth / 2;
            var rightValueY = bottomY - rightValueDims[1] / 2;
            var rightUnitY = bottomY - rightUnitDims[1] / 2;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(rightStartX + rightValueDims[0] / 2, rightValueY, labelFont, rightData.get(:value), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(rightStartX + rightValueDims[0] + 4 + rightUnitDims[0] / 2, rightUnitY, unitFont, rightData.get(:unit), Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    //! 绘制四字段田字布局
    private function drawLayout4(
        dc as Dc,
        data as Array,
        startY as Number,
        width as Number,
        height as Number
    ) as Void {
        var labelFont = getLabelFont();
        var unitFont = getUnitFont();

        var halfWidth = width / 2;
        var halfHeight = height / 2;

        // 田字四个位置
        var pos0X = halfWidth / 2;
        var pos0Y = startY + halfHeight / 2;
        var pos1X = halfWidth + halfWidth / 2;
        var pos1Y = startY + halfHeight / 2;
        var pos2X = halfWidth / 2;
        var pos2Y = startY + halfHeight + halfHeight / 2;
        var pos3X = halfWidth + halfWidth / 2;
        var pos3Y = startY + halfHeight + halfHeight / 2;

        var positionsX = [pos0X, pos1X, pos2X, pos3X];
        var positionsY = [pos0Y, pos1Y, pos2Y, pos3Y];

        for (var i = 0; i < 4; i++) {
            var posX = positionsX[i];
            var posY = positionsY[i];
            var fieldData = data[i];

            var valueDims = dc.getTextDimensions(fieldData.get(:value), labelFont);
            var unitDims = dc.getTextDimensions(fieldData.get(:unit), unitFont);
            var totalWidth = valueDims[0] + 4 + unitDims[0];
            var startX = posX - totalWidth / 2;
            var valueY = posY - valueDims[1] / 2;
            var unitY = posY - unitDims[1] / 2;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(startX + valueDims[0] / 2, valueY, labelFont, fieldData.get(:value), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(startX + valueDims[0] + 4 + unitDims[0] / 2, unitY, unitFont, fieldData.get(:unit), Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    //! 格式化速度
    private function formatSpeed(speed as Numeric) as String {
        var rounded = Math.round(speed).toNumber();
        if (rounded > 99) {
            rounded = 99;
        }
        return rounded.toString();
    }

    //! 格式化功率
    private function formatPower(power as Numeric) as String {
        if (power > 9999) {
            power = 9999;
        }
        return power.toNumber().toString();
    }

    //! 格式化心率
    private function formatHeartRate(hr as Numeric) as String {
        if (hr > 999) {
            hr = 999;
        }
        return hr.toNumber().toString();
    }

    //! 格式化坡度
    private function formatGrade(grade as Numeric) as String {
        return grade.format("%.1f");
    }

    function onUpdate(dc as Dc) as Void {
        // System.println(
        //     "HR=" + mHeartRate + " SPD=" + mSpeed + " PWR=" + mPower
        // );

        var bgColor = getBackgroundColor();
        var width = dc.getWidth();
        var height = dc.getHeight();

        // 设置背景色
        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        // 准备数据
        var data = new [4];

        // 根据字段数量准备数据
        // 顺序: 心率、速度、功率、坡度
        if (mFieldCount >= 1) {
            data[0] = { :value => formatHeartRate(mHeartRate), :unit => "bpm" };
        }
        if (mFieldCount >= 2) {
            data[1] = { :value => formatSpeed(mSpeed), :unit => "kpm" };
        }
        if (mFieldCount >= 3) {
            data[2] = { :value => formatPower(mPower), :unit => "w" };
        }
        if (mFieldCount >= 4) {
            data[3] = { :value => formatGrade(mGrade), :unit => "%" };
        }

        // 根据字段数量选择布局
        var startY = 0;
        if (mFieldCount == 1) {
            drawLayout1(dc, data, startY, width, height);
        } else if (mFieldCount == 2) {
            drawLayout2(dc, data, startY, width, height);
        } else if (mFieldCount == 3) {
            drawLayout3(dc, data, startY, width, height);
        } else if (mFieldCount == 4) {
            drawLayout4(dc, data, startY, width, height);
        }

        // 不再调用 View.onUpdate(dc)，因为我们已经直接绘制了
    }
}
