tell application "Microsoft PowerPoint"
	activate
	
	set sourcePath to POSIX file "/Users/moonviz/Workbench/openclaw-profile/editor-01/workspace/副护士长竞聘汇报.pptx"
	set targetPath to POSIX file "/Users/moonviz/Workbench/openclaw-profile/editor-01/workspace/20260331038--竞聘-定稿.pptx"
	set outputPath to POSIX file "/Users/moonviz/Workbench/openclaw-profile/editor-01/workspace/20260331038--竞聘-定稿_套用模板_final.pptx"
	
	-- 打开源模板
	open sourcePath
	set sourcePres to active presentation
	
	-- 打开目标
	open targetPath
	set targetPres to active presentation
	
	-- 应用模板
	apply design to targetPres from sourcePres
	
	-- 保存
	save targetPres in outputPath
	
	-- 关闭
	close sourcePres saving no
	close targetPres saving no
	
	display dialog "完成！"
end tell
