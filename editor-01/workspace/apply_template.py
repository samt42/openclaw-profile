#!/usr/bin/env python3
"""
从第一个PPT提取模板并应用到第二个PPT
"""

from pptx import Presentation
from pptx.util import Inches, Pt
import copy
import os

def apply_template(source_path, target_path, output_path):
    """
    将source的模板应用到target，保存为output
    """
    print(f"读取源模板: {source_path}")
    prs_source = Presentation(source_path)
    
    print(f"读取目标文件: {target_path}")
    prs_target = Presentation(target_path)
    
    # 创建新的演示文稿，使用源的模板
    prs_output = Presentation(source_path)
    
    # 清空默认生成的幻灯片
    for slide in list(prs_output.slides):
        rId = prs_output.slides._sldIdLst[-1].rId
        prs_output.part.drop_rel(rId)
        del prs_output.slides._sldIdLst[-1]
    
    # 复制target的内容到output
    print(f"开始复制幻灯片内容...")
    for slide_idx, target_slide in enumerate(prs_target.slides):
        print(f"  处理第 {slide_idx + 1} 张幻灯片")
        
        # 创建新幻灯片，使用源的布局
        # 优先匹配相同的布局类型，否则用第一个布局
        layout_idx = min(slide_idx, len(prs_output.slide_layouts) - 1)
        slide_layout = prs_output.slide_layouts[layout_idx]
        new_slide = prs_output.slides.add_slide(slide_layout)
        
        # 复制所有形状
        for shape in target_slide.shapes:
            copy_shape(shape, new_slide)
    
    print(f"保存结果到: {output_path}")
    prs_output.save(output_path)
    print("完成!")

def copy_shape(shape, target_slide):
    """
    复制一个形状到目标幻灯片
    """
    if shape.has_chart:
        # 图表
        print("    跳过图表 (图表复制比较复杂)")
        return
    
    if shape.has_table:
        # 表格
        print("    跳过表格 (表格复制比较复杂)")
        return
    
    if shape.shape_type == 13:  # 图片
        try:
            img_data = shape.image.blob
            img_left = shape.left
            img_top = shape.top
            img_width = shape.width
            img_height = shape.height
            
            # 添加图片
            target_slide.shapes.add_picture(
                img_data,
                img_left,
                img_top,
                img_width,
                img_height
            )
        except Exception as e:
            print(f"    图片复制失败: {e}")
        return
    
    # 文本框和其他形状
    try:
        # 获取位置和尺寸
        left = shape.left
        top = shape.top
        width = shape.width
        height = shape.height
        
        # 创建新形状
        if shape.shape_type == 1:  # 自动形状
            new_shape = target_slide.shapes.add_shape(
                shape.auto_shape_type,
                left, top, width, height
            )
        else:
            # 默认用文本框
            new_shape = target_slide.shapes.add_textbox(
                left, top, width, height
            )
        
        # 复制文本
        if shape.has_text_frame:
            # 清空默认文本
            if new_shape.has_text_frame:
                new_shape.text_frame.clear()
                
                # 复制段落
                for paragraph in shape.text_frame.paragraphs:
                    new_para = new_shape.text_frame.add_paragraph()
                    new_para.text = paragraph.text
                    new_para.level = paragraph.level
                    
                    # 复制字体样式
                    if paragraph.runs:
                        for run in paragraph.runs:
                            new_run = new_para.add_run()
                            new_run.text = run.text
                            if run.font:
                                new_run.font.name = run.font.name
                                new_run.font.size = run.font.size
                                new_run.font.bold = run.font.bold
                                new_run.font.italic = run.font.italic
                                new_run.font.color.rgb = run.font.color.rgb if hasattr(run.font.color, 'rgb') else None
        
        # 复制填充和线条样式
        if hasattr(shape, 'fill') and hasattr(new_shape, 'fill'):
            if shape.fill.type == 1:  # 纯色填充
                new_shape.fill.solid()
                if hasattr(shape.fill.fore_color, 'rgb'):
                    new_shape.fill.fore_color.rgb = shape.fill.fore_color.rgb
        
        if hasattr(shape, 'line') and hasattr(new_shape, 'line'):
            new_shape.line.color.rgb = shape.line.color.rgb if hasattr(shape.line.color, 'rgb') else None
            new_shape.line.width = shape.line.width
            
    except Exception as e:
        print(f"    形状复制失败: {e}")

if __name__ == "__main__":
    # 源模板文件（第一个PPT）
    source_file = "副护士长竞聘汇报.pptx"
    # 目标文件（第二个PPT）
    target_file = "20260331038--竞聘-定稿.pptx"
    # 输出文件
    output_file = "20260331038--竞聘-定稿_套用模板.pptx"
    
    if os.path.exists(source_file) and os.path.exists(target_file):
        apply_template(source_file, target_file, output_file)
    else:
        print("错误: 找不到文件!")
        print(f"源文件: {source_file} {'存在' if os.path.exists(source_file) else '不存在'}")
        print(f"目标文件: {target_file} {'存在' if os.path.exists(target_file) else '不存在'}")
