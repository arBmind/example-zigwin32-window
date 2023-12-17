const std = @import("std");
const zigwin32 = @import("zigwin32");

const WINAPI = std.os.windows.WINAPI;
const win32 = zigwin32.foundation;
const wam = zigwin32.ui.windows_and_messaging;
const gdi = zigwin32.graphics.gdi;
const _T = zigwin32.zig._T;
const FALSE = zigwin32.zig.FALSE;

pub fn wWinMain(hInstance: win32.HINSTANCE, _: ?win32.HINSTANCE, pCmdLine: [*:0]u16, nCmdShow: u32) u8 {
    _ = pCmdLine;
    const className = _T("Sample Window Class");
    const title = _T("Example Window");

    var wndClass = wam.WNDCLASSEX{
        .cbSize = @sizeOf(wam.WNDCLASSEX),
        .style = wam.WNDCLASS_STYLES.initFlags(.{ .VREDRAW = 1, .HREDRAW = 1 }),
        .lpfnWndProc = WindowProc,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = wam.LoadIcon(null, wam.IDI_APPLICATION),
        .hCursor = wam.LoadCursor(null, wam.IDC_ARROW),
        .hbrBackground = gdi.GetStockObject(gdi.WHITE_BRUSH),
        .lpszMenuName = null,
        .lpszClassName = className,
        .hIconSm = null,
    };
    _ = wam.RegisterClassEx(&wndClass);

    const hwnd = wam.CreateWindowEx(
        wam.WINDOW_EX_STYLE.initFlags(.{}),
        className, // Class name
        title, // Window name
        wam.WINDOW_STYLE.initFlags(.{ .SYSMENU = 1, .THICKFRAME = 1, .TILEDWINDOW = 1 }),
        wam.CW_USEDEFAULT,
        wam.CW_USEDEFAULT, // initial position
        wam.CW_USEDEFAULT,
        wam.CW_USEDEFAULT, // initial size
        null, // Parent
        null, // Menu
        hInstance,
        null, // WM_CREATE lpParam
    ) orelse return 1;

    _ = wam.ShowWindow(hwnd, @enumFromInt(nCmdShow));

    var msg = std.mem.zeroes(wam.MSG);
    while (wam.GetMessage(&msg, hwnd, 0, 0) > FALSE) {
        _ = wam.TranslateMessage(&msg);
        _ = wam.DispatchMessage(&msg);
    }
    return @intCast(msg.wParam);
}

fn RGB(r: u8, g: u8, b: u8) u32 {
    return r | (@as(u16, g) << 8) | (@as(u32, b) << 16);
}

fn WindowProc(window: win32.HWND, msg: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(WINAPI) win32.LRESULT {
    switch (msg) {
        wam.WM_DESTROY => {
            wam.PostQuitMessage(0);
            return 0;
        },
        wam.WM_PAINT => {
            var ps = std.mem.zeroes(gdi.PAINTSTRUCT);
            const hdc = gdi.BeginPaint(window, &ps);
            defer _ = gdi.EndPaint(window, &ps);

            const brush = gdi.CreateSolidBrush(RGB(255, 115, 55)) orelse return 0;
            _ = gdi.FillRect(hdc, &ps.rcPaint, brush);
            return 0;
        },
        else => {},
    }

    return wam.DefWindowProc(window, msg, wParam, lParam);
}
