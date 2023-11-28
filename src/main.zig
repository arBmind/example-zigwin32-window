const std = @import("std");
const win32 = @import("zigwin32");
const win_and_mess = win32.ui.windows_and_messaging;

pub fn main() !void {
    const className = "Sample Window Class";

    var wndClass: win_and_mess.WNDCLASSA = std.mem.zeroes(win_and_mess.WNDCLASSA);
    wndClass.lpszClassName = className;

    const instance = win32.system.library_loader.GetModuleHandleA(null);

    wndClass.hInstance = instance;
    wndClass.lpfnWndProc = WindowProc;

    _ = win_and_mess.RegisterClassA(&wndClass);

    const hwnd = win_and_mess.CreateWindowExA(win_and_mess.WINDOW_EX_STYLE.initFlags(.{}), className, "Example Window", win_and_mess.WINDOW_STYLE.initFlags(.{ .SYSMENU = 1, .THICKFRAME = 1, .TILEDWINDOW = 1 }), win_and_mess.CW_USEDEFAULT, win_and_mess.CW_USEDEFAULT, win_and_mess.CW_USEDEFAULT, win_and_mess.CW_USEDEFAULT, null, null, instance, null);

    if (hwnd == null) {
        return;
    }

    _ = win_and_mess.ShowWindow(hwnd, win_and_mess.SHOW_WINDOW_CMD.SHOWNORMAL);

    var msg = std.mem.zeroes(win_and_mess.MSG);

    while (win_and_mess.GetMessageA(&msg, hwnd, 0, 0) > 0) {
        _ = win_and_mess.TranslateMessage(&msg);
        _ = win_and_mess.DispatchMessageA(&msg);
    }
}

fn WindowProc(window: win32.foundation.HWND, msg: u32, wParam: usize, lParam: isize) callconv(.C) isize {
    switch (msg) {
        win_and_mess.WM_DESTROY => {
            win_and_mess.PostQuitMessage(0);
            return 0;
        },
        win_and_mess.WM_PAINT => {
            var ps = std.mem.zeroes(win32.graphics.gdi.PAINTSTRUCT);
            var hdc = win32.graphics.gdi.BeginPaint(window, &ps);

            var color = extern struct { r: u8 = 255, g: u8 = 115, b: u8 = 55, a: u8 = 0 }{};

            const brush = win32.graphics.gdi.CreateSolidBrush(@bitCast(color));

            _ = win32.graphics.gdi.FillRect(hdc, &ps.rcPaint, @as(win32.graphics.gdi.HBRUSH, brush.?));

            _ = win32.graphics.gdi.EndPaint(window, &ps);
            return 0;
        },
        else => {},
    }

    return win_and_mess.DefWindowProcA(window, msg, wParam, lParam);
}
