// 外链式（链入式）JavaScript：s1.js
// 本文件通过 <script src="s1.js"></script> 引入

// 页面加载后显示当前时间
function showTime() {
  var now = new Date();
  var el = document.getElementById("time");
  if (el) {
    el.innerHTML = "页面打开时间：" + now.toLocaleString("zh-CN");
  }
}

showTime();
