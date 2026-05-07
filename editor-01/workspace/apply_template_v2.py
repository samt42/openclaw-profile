#!/usr/bin/env python3
"""
PPTX模板应用 - 通过替换主题和样式文件
"""

import zipfile
import tempfile
import shutil
import os

def apply_template(source_path, target_path, output_path):
    """
    将source的主题/模板应用到target
    """
    print(f"读取源模板: {source_path}")
    print(f"读取目标文件: {target_path}")
    
    # 创建临时目录
    with tempfile.TemporaryDirectory() as temp_dir:
        source_dir = os.path.join(temp_dir, "source")
        target_dir = os.path.join(temp_dir, "target")
        output_dir = os.path.join(temp_dir, "output")
        
        os.makedirs(source_dir)
        os.makedirs(target_dir)
        
        # 解压两个PPTX
        with zipfile.ZipFile(source_path, 'r') as zip_ref:
            zip_ref.extractall(source_dir)
            
        with zipfile.ZipFile(target_path, 'r') as zip_ref:
            zip_ref.extractall(target_dir)
            
        # 复制整个目标文件到输出
        shutil.copytree(target_dir, output_dir)
        
        # 复制主题相关的文件
        theme_files = [
            ("ppt/theme/theme1.xml", True),
            ("ppt/_rels/presentation.xml.rels", True),
            ("ppt/presentation.xml", False),  # 慎重，可能会破坏布局
            ("ppt/slideMasters", True),
            ("ppt/slideLayouts", True),
            ("ppt/tableStyles.xml", True),
            ("ppt/theme", True)
        ]
        
        for file_path, replace in theme_files:
            src = os.path.join(source_dir, file_path)
            dst = os.path.join(output_dir, file_path)
            
            if os.path.exists(src):
                if os.path.isdir(src):
                    if os.path.exists(dst):
                        shutil.rmtree(dst)
                    shutil.copytree(src, dst)
                    print(f"  复制目录: {file_path}")
                else:
                    shutil.copy2(src, dst)
                    print(f"  复制文件: {file_path}")
        
        # 重新打包
        print(f"重新打包PPTX...")
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for root, dirs, files in os.walk(output_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, output_dir)
                    zipf.write(file_path, arcname)
    
    print(f"完成! 输出文件: {output_path}")

if __name__ == "__main__":
    # 源模板文件（第一个PPT）
    source_file = "副护士长竞聘汇报.pptx"
    # 目标文件（第二个PPT）
    target_file = "20260331038--竞聘-定稿.pptx"
    # 输出文件
    output_file = "20260331038--竞聘-定稿_套用模板_v2.pptx"
    
    if os.path.exists(source_file) and os.path.exists(target_file):
        apply_template(source_file, target_file, output_file)
    else:
        print("错误: 找不到文件!")
