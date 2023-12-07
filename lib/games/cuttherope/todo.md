https://github.com/yell0wsuit/CutTheRope
sprite rect在代码里，搜索rects
* asset准备 ok
    * bg
    * 绳子
    * 糖果
    * 角色
    * 固定栓
* 动画实体
    * 背景 ok
    * 角色：eat idle动作，idle 随机触发 ok
    * 角色底座 ok
    * 糖果 ok
    * 星星idle动画和被吃动画 ok
    * 固定点 ok
* 绳子模拟
    * 多个rigidbody模拟，参数调整 ok
    * 挂载candy，支持外部挂在component ok
    * 手势切断,  raycast 和绳子body检测 ok
    * 断开后渲染支持 ok
* 糖果交互
    * 糖果里角色近时张嘴，糖果消失 ok
    * 糖果碰到星星 ok

#  文案大纲
## 准备游戏角色
* 背景，sprite
* 小怪兽，sprite动画，idle和eat，底座
* 糖果，拼接两个sprite
* 固定栓，拼接两个sprite
* 星星，idle动画和消失动画

## 绳子
* 物理模拟
* 渲染绘制
* 切断模拟

## 吃星星

## 吃糖果
