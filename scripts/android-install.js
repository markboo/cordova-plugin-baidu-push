#!/usr/bin/env node

module.exports = function (context) {
    var bdpath         = context.requireCordovaModule('path'),
        bdfs           = context.requireCordovaModule('fs'),
        bdshell        = context.requireCordovaModule('shelljs'),
        bdprojectRoot  = context.opts.projectRoot,
        ConfigParser = context.requireCordovaModule("cordova-common").ConfigParser,
        bdconfig       = new ConfigParser(bdpath.join(context.opts.projectRoot, "config.xml")),
        bdpackageName = bdconfig.android_packageName() || bdconfig.packageName();
        
    if (!bdpackageName) {
        console.error("Package name could not be found!");
        return ;
    }

    // android platform available?
    if (context.opts.cordova.platforms.indexOf("android") === -1) {
        console.info("Android platform has not been added.");
        return ;
    }

    var bdtargetDir  = bdpath.join(bdprojectRoot, "platforms", "android", "src", "org.apache.cordova.baidu".replace(/\./g, bdpath.sep));
        bdtargetFile = bdpath.join(bdtargetDir, "BaiduPushReceiver.java");
        
    if (['after_plugin_add', 'after_plugin_install', 'after_platform_add'].indexOf(context.hook) === -1) {
        // remove it?
        try {
            bdfs.unlinkSync(bdtargetFile);
        } catch (err) {}
    } else {
        // create directory
        bdshell.mkdir('-p', bdtargetDir);

        // sync the content
        bdfs.readFile(bdpath.join(context.opts.plugin.dir, 'src', 'android', 'BaiduPushReceiver.java'), {encoding: 'utf-8'}, function (err, bddata) {
            if (err) {
                throw err;
            }

            bddata = bddata.replace(/^import __PACKAGE_NAME__;/m, 'import ' + bdpackageName + '.MainActivity;');
            bdfs.writeFileSync(bdtargetFile, bddata);
        });
    }
};