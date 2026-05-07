-- AppleScript: 将一个PPT的模板应用到另一个PPT
-- 使用PowerPoint来操作

on run argv
    set sourcePath to POSIX file (item 1 of argv) as string
    set targetPath to POSIX file (item 2 of argv) as string
    set outputPath to POSIX file (item 3 of argv) as string
    
    tell application "Microsoft PowerPoint"
        activate
        
        -- 打开源模板
        open sourcePath
        set sourcePres to active presentation
        
        -- 打开目标文件
        open targetPath
        set targetPres to active presentation
        
        -- 应用源的设计模板到目标
        set sourceDesign to slide master of sourcePres
        apply design to targetPres from sourcePres
        
        -- 保存
        save targetPres in outputPath
        
        -- 关闭
        close sourcePres saving no
        close targetPres saving no
        
    end tell
end run
