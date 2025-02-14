<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="https://kit.fontawesome.com/c9057320ee.js" crossorigin="anonymous"></script>
<link rel="stylesheet" type="text/css" href="MyPagest.css?v=1.2">
</head>
<%
request.setCharacterEncoding("utf-8");
String userId = "none";
HttpSession session = request.getSession(false);
if(session != null && session.getAttribute("login.id") != null) {
	userId = (String) session.getAttribute("login.id");
} else{
	response.sendRedirect("information.jsp");
    return;
}

Connection con = DsCon.getConnection();
PreparedStatement pstmt = null;
ResultSet rs = null;
try {
	if(userId != "none") {
		String sql = "SELECT * FROM users WHERE user_id=?";
		pstmt = con.prepareStatement(sql);
		pstmt.setString(1, userId);
		rs = pstmt.executeQuery();
		rs.next();
	}
%>
<body>
	<header style="padding:0 100px;">
		<a href="index.jsp" class="logo">Baekjunior</a>
		<div>
			<ul onmouseover="opendiv()" onmouseout="closediv()" style="height:130px;">
				<li><img src="img/user.png" style="width:30px;"></li>
				<li><a href="#"><%=userId %></a></li>
			</ul>
			<div id="myprodiv" onmouseover="opendiv()" onmouseout="closediv()" style="display:none;position:fixed;top: 100px;background: white;padding: 17px;border: 3px solid black;margin-right: 20px;width: 200px;">
				<img src="./upload/<%=rs.getString("savedFileName") %>" alt="profileimg" style="border-radius:70%;width:70px;">
				<a href="MyPage.jsp" style="position:absolute;top:30px;margin-left:20px;text-decoration: none;color: black;"><%=userId %></a>
				<a href="logout_do.jsp" style="border: 1px solid;width: 90px;display:inline-block;text-align: center;height: 30px;position:absolute;top:60px;margin-left:8px;text-decoration: none;color: black;">로그아웃</a>
			</div>
		</div>
		<%
		pstmt.close();
		rs.close();
		} catch (SQLException e){
			out.print(e);
			return;
		}	
		%>
		<!-- 프로필, 로그아웃 div 띄우기 -->
		<script>
		function opendiv() {
			document.getElementById("myprodiv").style.display = "block";
		}
		function closediv() {
			document.getElementById("myprodiv").style.display = "none";
		}
		</script>
	</header>
	
	<script type="text/javascript">
		window.addEventListener("scroll", function(){
			var header= document.querySelector("header");
			header.classList.toggle("sticky", window.scrollY > 0);
		});
	</script>
	
	<section class="banner">
		<a href="#" class="logo"></a>
	</section>
	<div class="contents">
		<div class="menu">
			<div class="menu_box">
				<ul>
					<li><a href="#">내 활동</a></li>
					<li><a href="editProfile.jsp">프로필 수정</a></li>
				</ul>
			</div>
		</div>
		<div class="inner_contents">
			<div class="select_div">
				<Button class="note_div" onclick="location.href='gather_note.jsp'">
					<div>
						<h3>노트</h3>
						<p>35</p>
						<i class="fa-solid fa-note-sticky fa-lg"></i>
					</div>
				</Button>
				<Button class="draft_div" onclick="location.href='#'">
					<div>
						<h3>임시저장</h3>
						<p>3</p>
						<i class="fa-solid fa-box-open fa-lg"></i>
					</div>
				</Button>
				<Button class="bookmark_div" onclick="location.href='#'">
					<div>
						<h3>북마크</h3>
						<p>15</p>
						<i class="fa-solid fa-bookmark fa-lg"></i>
					</div>
				</Button>
			</div>
			<div class="calender">
				<div class="calender_box">
					<h2>2024년 8월</h2>
					<table>
						<tr>
							<th>일</th>
							<th>월</th>
							<th>화</th>
							<th>수</th>
							<th>목</th>
							<th>금</th>
							<th>토</th>
						</tr>
						<tr>
							<td><div>
								
							</div></td>
							<td><div>
								
							</div></td>
							<td><div>
								
							</div></td>
							<td><div>
								
							</div></td>
							<td><div>
								<p>1</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>2</p>
								<p>1</p>
							</div></td>
							<td><div>
								<p>3</p>
								<p>3</p>
							</div></td>
						</tr>
						<tr>
							<td><div>
								<p>4</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>5</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>6</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>7</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>8</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>9</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>10</p>
								<p>3</p>
							</div></td>
						</tr>
						<tr>
							<td><div>
								<p>11</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>12</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>13</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>14</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>15</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>16</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>17</p>
								<p>3</p>
							</div></td>
						</tr>
						<tr>
							<td><div>
								<p>18</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>19</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>20</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>21</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>22</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>23</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>24</p>
								<p>3</p>
							</div></td>
						</tr>
						<tr>
							<td><div>
								<p>25</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>26</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>27</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>28</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>29</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>30</p>
								<p>3</p>
							</div></td>
							<td><div>
								<p>31</p>
								<p>3</p>
							</div></td>
						</tr>
					</table>
				</div>
			</div>
		</div>
	</div>
	
	
</body>
</html>