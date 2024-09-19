#!/usr/bin/env gjs

const GLib = imports.gi.GLib;
const Gio = imports.gi.Gio;


function setUnsafeMode(enable) {
    let session = Gio.DBus.session;
    let flags = Gio.DBusCallFlags.NONE;
    let timeout = -1;

    let script = `
        if (global.context && 'unsafe_mode' in global.context) {
            global.context.unsafe_mode = ${enable};
            global.context.unsafe_mode;
        } else {
            "Property not accessible";
        }
    `;

    session.call(
        'org.gnome.Shell',
        '/org/gnome/Shell',
        'org.gnome.Shell',
        'Eval',
        new GLib.Variant('(s)', [script]),
        null,
        flags,
        timeout,
        null,
        (connection, result) => {
            try {
                let [, variant] = connection.call_finish(result);
                let [success, value] = variant.deep_unpack();
                if (success) {
                    print(`Attempt to set unsafe_mode to ${enable} completed. Current value: ${value}`);
                } else {
                    print(`Failed to set unsafe_mode. Result: ${value}`);
                }
            } catch (e) {
                print('Error: ' + e.message);
            }
        }
    );
}

function restartGnome() {
    let session = Gio.DBus.session;
    let flags = Gio.DBusCallFlags.NONE;
    let timeout = -1;

    session.call(
        'org.gnome.Shell',
        '/org/gnome/Shell',
        'org.gnome.Shell',
        'Eval',
        new GLib.Variant('(s)', ['global.reexec_self()']),
        null,
        flags,
        timeout,
        null,
        (connection, result) => {
            try {
                connection.call_finish(result);
                print('GNOME Shell restarted successfully.');
            } catch (e) {
                print('Failed to restart GNOME Shell: ' + e.message);
            }
        }
    );
}

setUnsafeMode(true);
restartGnome();
