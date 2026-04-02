import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class datasin1View extends WatchUi.DataField {
    hidden var mPower as Numeric; // Monkey 中 hidden 关键字表示该变量为 Monkey 中隐藏的变量，不会被导出。
    hidden var mSpeed as Numeric;
    hidden var mHeartRate as Numeric;
    hidden var mLayoutMode as Symbol;

    function initialize() {
        DataField.initialize();
        mPower = 0;
        mSpeed = 0.0f;
        mHeartRate = 0;
        mLayoutMode = :full;
    }

    // 布局 dc是画布对象
    function onLayout(dc as Dc) as Void {
        // 是否被遮挡标志
        var obscurityFlags = DataField.getObscurityFlags();

        // 全屏 - 三行布局
        if (obscurityFlags == 0) {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            mLayoutMode = :full;
            // 左上 - 只显示功率
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));
            (View.findDrawableById("label") as Text).setText("PWR");
            mLayoutMode = :power;
            // 右上 - 只显示速度
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));
            (View.findDrawableById("label") as Text).setText("SPD");
            mLayoutMode = :speed;
            // 左下 - 只显示心率
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));
            (View.findDrawableById("label") as Text).setText("HR");
            mLayoutMode = :heartRate;
            // 右下 - 三行紧凑布局
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));
            mLayoutMode = :compact;
        }
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
    }

    function onUpdate(dc as Dc) as Void {
        var bgColor = getBackgroundColor();
        (View.findDrawableById("Background") as Text).setColor(bgColor);

        var textColor =
            bgColor == Graphics.COLOR_BLACK
                ? Graphics.COLOR_WHITE
                : Graphics.COLOR_BLACK;

        // 全屏模式和紧凑模式 - 三行显示
        if (mLayoutMode == :full || mLayoutMode == :compact) {
            var labelHr = View.findDrawableById("labelHr") as Text?;
            var valueHr = View.findDrawableById("valueHr") as Text?;
            var labelSpd = View.findDrawableById("labelSpd") as Text?;
            var valueSpd = View.findDrawableById("valueSpd") as Text?;
            var labelPwr = View.findDrawableById("labelPwr") as Text?;
            var valuePwr = View.findDrawableById("valuePwr") as Text?;

            if (labelHr != null) {
                labelHr.setColor(Graphics.COLOR_LT_GRAY);
            }
            if (valueHr != null) {
                valueHr.setColor(textColor);
                valueHr.setText(mHeartRate.toString());
            }
            if (labelSpd != null) {
                labelSpd.setColor(Graphics.COLOR_LT_GRAY);
            }
            if (valueSpd != null) {
                valueSpd.setColor(textColor);
                valueSpd.setText(mSpeed.format("%.1f"));
            }
            if (labelPwr != null) {
                labelPwr.setColor(Graphics.COLOR_LT_GRAY);
            }
            if (valuePwr != null) {
                valuePwr.setColor(textColor);
                valuePwr.setText(mPower.toString());
            }
        }

        // 半屏模式 - 单值显示
        if (
            mLayoutMode == :power ||
            mLayoutMode == :speed ||
            mLayoutMode == :heartRate
        ) {
            var value = View.findDrawableById("value") as Text?;
            if (value != null) {
                value.setColor(textColor);
                if (mLayoutMode == :power) {
                    value.setText(mPower.toString());
                } else if (mLayoutMode == :speed) {
                    value.setText(mSpeed.format("%.1f"));
                } else if (mLayoutMode == :heartRate) {
                    value.setText(mHeartRate.toString());
                }
            }
        }

        View.onUpdate(dc);
    }
}
