tell application "Keynote"
	activate
	
	set sourcePath to POSIX file "/Users/moonviz/Workbench/openclaw-profile/editor-01/workspace/副护士长竞聘汇报.pptx"
	set targetPath to POSIX file "/Users/moonviz/Workbench/openclaw-profile/editor-01/workspace/20260331038--竞聘-定稿.pptx"
	set outputPath to POSIX file "/Users/moonviz/Workbench/openclaw-profile/editor-01/workspace/20260331038--竞聘-定稿_套用模板_keynote.pptx"
	
	-- 打开源文件
	open sourcePath
	delay 1
	set sourceDoc to front document
	
	-- 打开目标文件
	open targetPath
	delay 1
	set targetDoc to front document
	
	tell targetDoc
		-- 复制母版
		repeat with i from 1 to count of master slides of sourceDoc
			set newMaster to make new master slide at end
			-- 这里需要更复杂的复制逻辑...
		end repeat
	end tell
	
	-- 保存
	save targetDoc in outputPath
	
	-- 关闭
	close sourceDoc saving no
	close targetDoc saving no
	
	display dialog "尝试完成！"
end tell
