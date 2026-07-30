using System.Globalization;
using Avalonia;
using Avalonia.Data.Converters;
using Avalonia.Media;

namespace Taskly.Converters;

/// <summary>布尔取反。</summary>
public class BoolInverterConverter : IValueConverter
{
    public static readonly BoolInverterConverter Instance = new();

    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
        => value is bool b ? !b : value;

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => value is bool b ? !b : value;
}

/// <summary>bool → Visibility（true 可见）。</summary>
public class BoolToVisibilityConverter : IValueConverter
{
    public static readonly BoolToVisibilityConverter Instance = new();

    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
        => value is bool b && b;

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => value is bool b && b;
}

/// <summary>int → 可见性（&gt; 0 可见）。用于计数 badge。</summary>
public class CountToVisibilityConverter : IValueConverter
{
    public static readonly CountToVisibilityConverter Instance = new();

    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is int i)
        {
            return i > 0;
        }

        return false;
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

/// <summary>int 转字符串（用于显示计数，0 显示空）。</summary>
public class CountToStringConverter : IValueConverter
{
    public static readonly CountToStringConverter Instance = new();

    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is int i && i > 0)
        {
            return i.ToString(CultureInfo.InvariantCulture);
        }

        return string.Empty;
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

/// <summary>ARGB int → Color（兼容原 .db 颜色存储）。</summary>
public class ArgbToColorConverter : IValueConverter
{
    public static readonly ArgbToColorConverter Instance = new();

    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is int i)
        {
            return Color.FromUInt32((uint)i);
        }

        if (value is uint u)
        {
            return Color.FromUInt32(u);
        }

        return Colors.Transparent;
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => value is Color c ? (int)c.ToUInt32() : 0;
}

/// <summary>字符串非空 → 可见。</summary>
public class StringToVisibilityConverter : IValueConverter
{
    public static readonly StringToVisibilityConverter Instance = new();

    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
        => !string.IsNullOrEmpty(value as string);

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

/// <summary>Color? → Brush（null 返回透明）。</summary>
public class ColorToBrushConverter : IValueConverter
{
    public static readonly ColorToBrushConverter Instance = new();

    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is Color c)
        {
            return new SolidColorBrush(c);
        }

        return Brushes.Transparent;
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => value is SolidColorBrush b ? b.Color : Avalonia.Media.Colors.Transparent;
}

/// <summary>多值：null 合并（取第一个非 null）。用于颜色回退。</summary>
public class FirstNonNullConverter : IMultiValueConverter
{
    public static readonly FirstNonNullConverter Instance = new();

    public object Convert(IList<object?> values, Type targetType, object? parameter, CultureInfo culture)
    {
        var unset = AvaloniaProperty.UnsetValue;
        foreach (var v in values)
        {
            if (v is not null && !ReferenceEquals(v, unset))
            {
                return v;
            }
        }

        return unset;
    }
}
