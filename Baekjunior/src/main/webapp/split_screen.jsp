<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>create_note</title>
<link rel="stylesheet" href="Baekjunior_css.css">

<style>
a{
	text-decoration: none;
	color:black;
}
</style>
</head>

<script type="text/javascript">
	function updateWindowHeight() {
	    let splitDiv1 = document.getElementById("split1");
	    let splitDiv2 = document.getElementById("split2");
	    splitDiv1.style.height = (window.innerHeight - 160) + "px";
	    splitDiv2.style.height = (window.innerHeight - 160) + "px";
	    
	    console.log("현재 window.innerHeight 값:", window.innerHeight);
	}
	
	// 페이지 로드 시 실행
	window.onload = updateWindowHeight;
	
	// 창 크기가 변경될 때 실행
	window.addEventListener("resize", updateWindowHeight);

    function confirmDeletion(problemIdx) {
        var result = confirm("정말 삭제하시겠습니까?");
        if (result) {
            window.location.href = "note_delete_do.jsp?problem_idx=" + problemIdx;
        } else {
            return false;
        }
    }
</script>

<script>	
	// 고정 여부 업데이트하는 함수
	function updatePin(problemIdx) {
	    var pinIcon = document.getElementById('content_set_a_' + problemIdx);
	    let fix = 0;
	    
		if(pinIcon.offsetWidth > 0 && pinIcon.offsetHeight > 0) {
			pinIcon.style.display = 'none';
			fix = 0;
		} else {
			pinIcon.style.display = 'inline-block';
			fix = 1;
		}
	  
		const xhr = new XMLHttpRequest();
	    xhr.open("POST", "updatePin.jsp", true);
	    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	    xhr.onreadystatechange = function () {
	        if (xhr.readyState === 4 && xhr.status === 200) {
	            console.log(xhr.responseText);  
	        }
	    };
	    xhr.send("problem_idx=" + problemIdx +"&is_fixed=" + fix);
	}
</script>

<script>
<%
request.setCharacterEncoding("utf-8");
String userId = "none";
HttpSession session = request.getSession(false);
if(session != null && session.getAttribute("login.id") != null) {
	userId = (String) session.getAttribute("login.id");
}

String temp = "";
temp = request.getParameter("problem_idx1");
int problemIdx1 = (temp == null ? -1 : (Integer.parseInt(temp)));

temp = request.getParameter("problem_idx2");
int problemIdx2 = (temp == null ? -1 : (Integer.parseInt(temp)));

if(problemIdx1 == -1 && problemIdx2 == -1){
	response.sendRedirect("index.jsp"); 
    return;
}

Connection con = DsCon.getConnection();

PreparedStatement pstmt = null;
ResultSet rs = null;

PreparedStatement pstmt2 = null;
ResultSet rs2 = null;

PreparedStatement pstmt3 = null;
ResultSet rs3 = null;

PreparedStatement pstmt4 = null;
ResultSet rs4 = null;

PreparedStatement pstmt5 = null;
ResultSet rs5 = null;

PreparedStatement pstmt6 = null;
ResultSet rs6 = null;
%>
</script>

<body>	
	<header style="padding:0px 100px;">
		<a href="index.jsp" class="logo">Baekjunior</a>
		<div id="main_menu">
			<ul>
				<li class="main_menu_Storage"><a href="#">Storage</a>
					<ul>
						<li><a href="index.jsp">ALL</a></li>
						<li><a href="index.jsp?type=bookmark">BOOKMARK</a></li>
						<li><a href="#">CATEGORY</a></li>
						<li><a href="#">LEVEL</a></li>
					</ul>
				</li>				
				<li class="main_menu_Friend"><a href="#">Friend</a>
					<ul>
						<li><a href="#">friend1</a></li>
						<li><a href="#">friend2</a></li>
						<li><a href="#">friend3</a></li>
					</ul>
				</li>
				<li class="main_menu_Group"><a href="#">Group</a>
					<ul>
						<li><a href="#">group1</a></li>
						<li><a href="#">group2</a></li>
					</ul>
				</li>
				<li class="main_menu_MyPage"><a href="#">MyPage</a>
					<ul>
						<li><a href="#">mypage1</a></li>
						<li><a href="#">mypage2</a></li>
						<li><a href="#">mypage3</a></li>
						<li><a href="#">mypage4</a></li>
					</ul>
				</li>
				<li class="main_menu_Setting"><a href="#">Setting</a>
					<ul>
						<li><a href="#">setting1</a></li>
						<li><a href="#">setting2</a></li>
						<li><a href="#">setting3</a></li>
					</ul>
				</li>
			</ul>
		</div>
		<%
		try {
			if(userId != "none") {
				String sql = "SELECT * FROM users WHERE user_id=?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, userId);
				rs = pstmt.executeQuery();
				rs.next();
			}

		%>
		<div>
			<ul onmouseover="opendiv()" onmouseout="closediv()" style="height:100px;">
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
	
	<section class="banner" style="padding:40px 100px;">
		<a href="#" class="logo"></a>
	</section>
	
	<div style="position:absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);">
		<button onclick="location.href='split_screen.jsp?problem_idx1=<%=problemIdx2 %>&problem_idx2=<%=problemIdx1 %>'" style="border-right:3px solid black; font-size:15px; font-weight:bold; width:60px;">Switch Sides</button>
	</div>
	
	<div style="display:grid; grid-template-columns: 1fr 1fr; margin-top:50px;">
		<!-- 왼쪽 스크린 -->
		
		<!-- note가 나와야하는 경우 -->
		<%
		if(problemIdx1 != -1){
			try {
				String sql = "SELECT * FROM problems WHERE problem_idx=?";
				
				pstmt = con.prepareStatement(sql);
				pstmt.setInt(1, problemIdx1);
				rs = pstmt.executeQuery();
				
				if(rs.next()){
		%>
		
		<div id="split1" style="margin-top:20px; border-right:3px solid black; overflow-y:auto;">
			<div style="margin:0 50px 0 80px;">
				<div style="float:right;">
					<button onclick="location.href='split_screen.jsp?problem_idx1=-1&problem_idx2=<%=problemIdx2 %>'" style="font-size:15px; font-weight:bold; border:3px solid black; padding:0 5px;">X</button>
				</div>
				<br><br>
				<div>
					<div>
						<div style="display:inline; width:80%; font-size:25px; font-weight:bold;">
							#<span><%=rs.getInt("problem_id") %></span> : <span><%=rs.getString("problem_title") %></span> <span><img class="bookmark_star" src="img/star_on.png" style="width:18px;"></span>
						</div>
						<div style="float:right; font-size:15px; padding:10px;">
							Submit Date : <span><%=rs.getDate("submitDate") %></span>
						</div>
					</div>
					
					<div style="font-weight:bold; font-size:20px; margin-top:15px; margin-left:30px;">
						<!-- 티어 -->
						<div style="display:inline; margin-right:50px;">
							<%
							String tierName = rs.getString("tier_name"); 
							int tierNum = rs.getInt("tier_num");
							%>
							<span><img src="img/star_<%=tierName.toLowerCase()%>.png" height="15px"></span>
							<span> <%=tierName.toUpperCase()%> <%=tierNum %></span>
						</div>
						<!-- 알고리즘 종류 나열 -->
						<div style="display:inline; margin-right:25px;">
						<%
							String problemSortStr = rs.getString("problem_sort");
							String[] algorithmList = problemSortStr.split(",");
	                    	if(problemSortStr != null && !problemSortStr.trim().isEmpty()) {
	                    		for (String algo : algorithmList) {
	                            	if (!algo.isEmpty()) {   
						%>
							<span style="margin-right:25px;"><img src="img/dot1.png" style="width:15px;"> <%=algo %></span>
						<%
	                            	}
	                    		}
	                    	}
							else {
						%> <span style="margin-right:25px;"><img src="img/dot1.png" style="width:15px;"> default sort</span>
						<% } %>
						</div>
						<!-- 언어 종류 -->
						<div style="display:inline;">
							<span style="margin-right:50px;"><%=rs.getString("language") %></span>
						</div>
						<!-- 친구 -->
						<div style="display:inline;">
							Friends who solved : <span style="background:lightgray; font-size:15px; padding:3px 20px; border-radius:20px;">Dodam</span> <span style="background:lightgray; font-size:15px; padding:3px 20px; border-radius:20px;">Dam</span>
						</div>
					</div>
				</div>	
				
				<div style="font-weight:bold; font-size:20px; border:3px solid black; background:#5F99EB; padding:30px; margin-top:50px; vertical-align:middle; ">
				<%
					String subMemoStr = rs.getString("sub_memo");
					String[] subMemos = subMemoStr != null ? subMemoStr.split("\n") : new String[]{};
					
					if(subMemoStr == null){
				%>
						<div>not exist</div>
				<%
					}
					else{
				%>
				<% for (String memo : subMemos) { %>
					<div style="padding:5px;">
						<img src="img/arrow3.png" style="width:13px;"> <span><%=memo %></span>
					</div>
		        <% }
				} %>
				</div>
				
				<div style="display: grid; margin-top: 50px; grid-template-columns: 5fr 2fr; column-gap: 30px; font-size: 20px;">
			        <div style="column-gap: 10px; border: 3px solid black; background: white; padding: 10px;">
			            <div id="code-editor" style="display: grid; grid-template-columns: 1fr 17fr; border: none;">
			                <textarea class="notes" id="lineNumbers" rows="10" wrap="off" style="text-align:center; padding-bottom:0px;" readonly></textarea>
			                <textarea class="notes" id="code_note" rows="10" placeholder="Enter your code here..." wrap="off" style="overflow-x:auto; padding-bottom:60px;" readonly><%=rs.getString("code") %></textarea>
			            </div>
			        </div>
			        
			
			        <div style="column-gap: 10px; border: 3px solid black; background: white; padding: 10px;">
			            <div id="code-editor" style="border: none;">
			                <textarea class="notes" id="note_detail" rows="10" placeholder="Enter your code memo here..." wrap="off" style="overflow-x:auto; padding-bottom:60px;" readonly><%=rs.getString("main_memo") %></textarea>
			            </div>
			        </div>
		    	</div>
		    </div>
	    
			
	
			
			<script>
	        const textarea = document.getElementById('code_note');
	        const lineNumbers = document.getElementById('lineNumbers');
	        const noteDetail = document.getElementById('note_detail');
					
	        function updateLineNumbers() {
	            const numberOfLines = textarea.value.split('\n').length;
	            let lineNumberString = '';
	            let noteDetailString = '';
	
	            for (let i = 1; i <= numberOfLines; i++) {
	                lineNumberString += i + '\n';
	                noteDetailString += "_" + '\n';
	            }
	
	            lineNumbers.value = lineNumberString;
	            noteDetail.value = noteDetailString;
	        }
	
	        function adjustHeight(element) {
	            element.style.height = 'auto'; // Reset height to auto to measure scrollHeight
	            element.style.height = element.scrollHeight + 'px'; // Adjust height to fit content
	        }
	
	        // Function to sync heights between textareas
	        function syncHeights() {
	            const maxScrollHeight = Math.max(textarea.scrollHeight, lineNumbers.scrollHeight, noteDetail.scrollHeight);
	            textarea.style.height = maxScrollHeight + 'px';
	            lineNumbers.style.height = maxScrollHeight + 'px';
	            noteDetail.style.height = maxScrollHeight + 'px';
	        }
	
	        // 초기 라인 번호 및 높이 업데이트
	        updateLineNumbers();
	        syncHeights();
	
	        // 사용자가 텍스트를 입력하거나 줄을 변경할 때 라인 번호 및 높이 업데이트
	        textarea.addEventListener('input', () => {
	            updateLineNumbers();
	            syncHeights();
	        });
	
	        // Scroll the line numbers to match the code textarea
	        textarea.addEventListener('scroll', () => {
	            lineNumbers.scrollTop = textarea.scrollTop;
	        });
	
	        function submitcode_note() {
	            const code = textarea.value;
	            console.log("Submitted C++ Code:", code);
	
	            // 서버에 코드를 전송하거나 WebAssembly로 처리하는 로직을 여기에 추가합니다.
	        }
	    	</script>
	    	
	    	
	    	
	    	
	    	
	    	
	    	<%	
					}
				} catch(SQLException e) {
		 			out.print(e);
		 			return;
		 		} finally{
		 			pstmt.close();
					rs.close();
		 		}	
			} else{
			%>
			
			
			<!-- 노트의 리스트가 나와야하는 경우 -->
		
			<div id="list_group" style="margin:0 50px;">
				<ul class="list">
			
			<%
			
		 		if (!userId.equals("none")) {
		 			try {
						String sql3 = "SELECT * FROM problems WHERE user_id=? AND problem_idx!=? AND problem_idx!=?";
		 				pstmt3 = con.prepareStatement(sql3);
		 				pstmt3.setString(1, userId);
		 				pstmt3.setInt(2, problemIdx1);
		 				pstmt3.setInt(3, problemIdx2);
		 				rs3 = pstmt3.executeQuery();
						
						String sql4 = "SELECT COUNT(*) FROM problems WHERE user_id=? AND problem_idx!=? AND problem_idx!=?";
		 				pstmt4 = con.prepareStatement(sql4);
		 				pstmt4.setString(1, userId);
		 				pstmt4.setInt(2, problemIdx1);
		 				pstmt4.setInt(3, problemIdx2);
		 				rs4 = pstmt4.executeQuery();
		 				
		 				if (rs4.next() && rs4.getInt(1) <= 0) {
		 					%>
		 					<div>
		 						not exist
		 					</div>
		 					<%
		 				} else {
		 					while (rs3.next()) {
		 		%>
		 		
		 			<li class="item">
		 				<div class="content_number"><a href="note_detail.jsp?problem_idx=<%=rs3.getInt("problem_idx")%>"># <%=rs3.getInt("problem_id") %></a></div>
		 				<div class="content_set">
				    	<% if(rs3.getInt("is_fixed") == 1) { %>
			    			<img class="content_set_a" id="content_set_a_<%= rs3.getInt("problem_idx") %>" src="img/pin.png">
			    		<% } else { %>
			    			<img class="content_set_a" id="content_set_a_<%= rs3.getInt("problem_idx") %>" src="img/pin.png" style="display:none">
			    		<% } %>
			    		<button class="content_set_b"><img src="img/....png"></button>
			    		<ul>
		    				<li><a onclick="updatePin('<%=rs3.getInt("problem_idx") %>')" href="#">Unpin / Pin to top</a></li>
		    				<li><a href="split_screen.jsp?problem_idx1=<%=rs3.getInt("problem_idx")%>&problem_idx2=<%=problemIdx2 %>">Split screen</a></li>
		    				<li><a href="#">Setting</a></li>
		    				<li><a onclick="confirmDeletion('<%=rs3.getInt("problem_idx") %>')" href="#">Delete</a></li>
		    			</ul>
			    		</div>
		 				<div class="content_title"><a href="#"><%=rs3.getString("memo_title") %></a></div>
		 			</li>
		 		<%
		 					}
		 				}
		 			} catch(SQLException e) {
		 				out.print(e);
		 			} finally {
						pstmt3.close();
						rs3.close();
						pstmt4.close();
						rs4.close();
		 			}
		 		}
		 		
			}
			%>
			</ul>
		</div>
			
	
	
	<!-- 오른쪽 스크린 -->
	
	<!-- note가 나와야하는 경우 -->
	<%
		if(problemIdx2 != -1){
			try {
				String sql2 = "SELECT * FROM problems WHERE problem_idx=?";
				
				pstmt2 = con.prepareStatement(sql2);
				pstmt2.setInt(1, problemIdx2);
				rs2 = pstmt2.executeQuery();
				
				if(rs2.next()){
		%>
	
	<div id="split2" style="margin-top:20px; border-left:3px solid black; overflow-y:auto;">
		<div style="width:80%; margin:0 50px;">
			<div style="float:right;">
				<button onclick="location.href='split_screen.jsp?problem_idx1=<%=problemIdx1%>&problem_idx2=-1'" style="font-size:15px; font-weight:bold; border:3px solid black; padding:0 5px;">X</button>
			</div>
			<br><br>
			<div>
				<div>
					<div style="display:inline; width:80%; font-size:25px; font-weight:bold;">
						#<span><%=rs2.getInt("problem_id") %></span> : <span><%=rs2.getString("problem_title") %></span> <span><img class="bookmark_star" src="img/star_on.png" style="width:18px;"></span>
					</div>
					<div style="float:right; font-size:15px; padding:10px;">
						Submit Date : <span><%=rs2.getDate("submitDate") %></span>
					</div>
				</div>
				
				<div style="font-weight:bold; font-size:20px; margin-top:15px; margin-left:30px;">
					<!-- 티어 -->
					<div style="display:inline; margin-right:50px;">
						<%
						String tierName2 = rs2.getString("tier_name"); 
						int tierNum2 = rs2.getInt("tier_num");
						%>
						<span><img src="img/star_<%=tierName2.toLowerCase()%>.png" height="15px"></span>
						<span> <%=tierName2.toUpperCase()%> <%=tierNum2 %></span>
					</div>
					<!-- 알고리즘 종류 나열 -->
					<div style="display:inline; margin-right:25px;">
						<%
							String problemSortStr = rs2.getString("problem_sort");
							String[] algorithmList = problemSortStr.split(",");
	                    	if(problemSortStr != null && !problemSortStr.trim().isEmpty()) {
	                    		for (String algo : algorithmList) {
	                            	if (!algo.isEmpty()) {
						%>
							<span style="margin-right:25px;"><img src="img/dot1.png" style="width:15px;"> <%=algo %></span>
						<%
	                            	}
	                    		}
	                    	}
							else {
						%> 
						<span style="margin-right:25px;"><img src="img/dot1.png" style="width:15px;"> default sort</span>
						<% } %>
					</div>
					<div style="display:inline;">
						<span style="margin-right:50px;"><%=rs2.getString("language") %></span>
					</div>
					<div style="display:inline;">
						Friends who solved : <span style="background:lightgray; font-size:15px; padding:3px 20px; border-radius:20px;">Dodam</span> <span style="background:lightgray; font-size:15px; padding:3px 20px; border-radius:20px;">Dam</span>
					</div>
				</div>
			</div>	
			
			
			<!-- 서브 메모 -->
			<div style="font-weight:bold; font-size:20px; border:3px solid black; background:#5F99EB; padding:30px; margin-top:50px; vertical-align:middle; ">
				<%
					String subMemoStr = rs2.getString("sub_memo");
					String[] subMemos = subMemoStr != null ? subMemoStr.split("\n") : new String[]{};
					
					if(subMemoStr == null){
				%>
						<div>not exist</div>
				<%
					}
					else{
				%>
				<% for (String memo : subMemos) { %>
					<div style="padding:5px;">
						<img src="img/arrow3.png" style="width:13px;"> <span><%=memo %></span>
					</div>
		        <% }} %>
			</div>
			
			<div style="display: grid; margin-top: 50px; grid-template-columns: 5fr 2fr; column-gap: 30px; font-size: 20px;">
		        <div style="column-gap: 10px; border: 3px solid black; background: white; padding: 10px;">
		            <div id="code-editor" style="display: grid; grid-template-columns: 1fr 17fr; border: none;">
		                <textarea class="notes" id="lineNumbers" rows="10" wrap="off" style="text-align:center; padding-bottom:0px;" readonly></textarea>
		                <textarea class="notes" id="code_note" rows="10" placeholder="Enter your code here..." wrap="off" style="overflow-x:auto; padding-bottom:60px;" readonly><%=rs2.getString("code") %></textarea>
		            </div>
		        </div>
		        
		
		        <div style="column-gap: 10px; border: 3px solid black; background: white; padding: 10px;">
		            <div id="code-editor" style="border: none;">
		                <textarea class="notes" id="note_detail" rows="10" placeholder="Enter your code memo here..." wrap="off" style="overflow-x:auto; padding-bottom:60px;" readonly><%=rs2.getString("main_memo") %></textarea>
		            </div>
		        </div>
	    	</div>
    	</div>
    	
    	<script>
        const textarea = document.getElementById('code_note');
        const lineNumbers = document.getElementById('lineNumbers');
        const noteDetail = document.getElementById('note_detail');
				
        function updateLineNumbers() {
            const numberOfLines = textarea.value.split('\n').length;
            let lineNumberString = '';
            let noteDetailString = '';

            for (let i = 1; i <= numberOfLines; i++) {
                lineNumberString += i + '\n';
                noteDetailString += "_" + '\n';
            }

            lineNumbers.value = lineNumberString;
            noteDetail.value = noteDetailString;
        }

        function adjustHeight(element) {
            element.style.height = 'auto'; // Reset height to auto to measure scrollHeight
            element.style.height = element.scrollHeight + 'px'; // Adjust height to fit content
        }

        // Function to sync heights between textareas
        function syncHeights() {
            const maxScrollHeight = Math.max(textarea.scrollHeight, lineNumbers.scrollHeight, noteDetail.scrollHeight);
            textarea.style.height = maxScrollHeight + 'px';
            lineNumbers.style.height = maxScrollHeight + 'px';
            noteDetail.style.height = maxScrollHeight + 'px';
        }

        // 초기 라인 번호 및 높이 업데이트
        updateLineNumbers();
        syncHeights();

        // 사용자가 텍스트를 입력하거나 줄을 변경할 때 라인 번호 및 높이 업데이트
        textarea.addEventListener('input', () => {
            updateLineNumbers();
            syncHeights();
        });

        // Scroll the line numbers to match the code textarea
        textarea.addEventListener('scroll', () => {
            lineNumbers.scrollTop = textarea.scrollTop;
        });

        function submitcode_note() {
            const code = textarea.value;
            console.log("Submitted C++ Code:", code);

            // 서버에 코드를 전송하거나 WebAssembly로 처리하는 로직을 여기에 추가합니다.
        }
    	</script>
    	
    	
    	</div>
    	
    	
    	
    	
    	<%	
				}
			} catch(SQLException e) {
	 			out.print(e);
	 			return;
	 		} finally{
	 			pstmt2.close();
				rs2.close();
	 		}
		} else{
		%>
		
		<!-- 노트의 리스트가 나와야하는 경우 -->
		
		<div id="list_group" style="margin:0 50px;">
		<ul class="list">
		
		<%
		
	 		if (!userId.equals("none")) {
	 			try {
					String sql5 = "SELECT * FROM problems WHERE user_id=? AND problem_idx!=? AND problem_idx!=?";
	 				pstmt5 = con.prepareStatement(sql5);
	 				pstmt5.setString(1, userId);
	 				pstmt5.setInt(2, problemIdx1);
	 				pstmt5.setInt(3, problemIdx2);
	 				rs5 = pstmt5.executeQuery();
					
					String sql6 = "SELECT COUNT(*) FROM problems WHERE user_id=? AND problem_idx!=? AND problem_idx!=?";
	 				pstmt6 = con.prepareStatement(sql6);
	 				pstmt6.setString(1, userId);
	 				pstmt6.setInt(2, problemIdx1);
	 				pstmt6.setInt(3, problemIdx2);
	 				rs6 = pstmt6.executeQuery();
	 				
	 				if (rs6.next() && rs6.getInt(1) <= 0) {
	 					%>
	 					<div>
	 						not exist
	 					</div>
	 					<%
	 				} else {
	 					while (rs5.next()) {
	 						
	 						String move_url="";
	 		%>
	 		
	 			<li class="item">
	 				<div class="content_number"><a href="note_detail.jsp?problem_idx=<%=rs5.getInt("problem_idx")%>"># <%=rs5.getInt("problem_id") %></a></div>
	 				<div class="content_set">
			    	<% if(rs5.getInt("is_fixed") == 1) { %>
		    			<img class="content_set_a" id="content_set_a_<%= rs5.getInt("problem_idx") %>" src="img/pin.png">
		    		<% } else { %>
		    			<img class="content_set_a" id="content_set_a_<%= rs5.getInt("problem_idx") %>" src="img/pin.png" style="display:none">
		    		<% } %>
		    		<button class="content_set_b"><img src="img/....png"></button>
		    		<ul>
	    				<li><a onclick="updatePin('<%=rs5.getInt("problem_idx") %>')" href="#">Unpin / Pin to top</a></li>
	    				<li><a href="split_screen.jsp?problem_idx1=<%=problemIdx1%>&problem_idx2=<%=rs5.getInt("problem_idx")%>">Split screen</a></li>
	    				<li><a href="#">Setting</a></li>
	    				<li><a onclick="confirmDeletion('<%=rs5.getInt("problem_idx") %>')" href="#">Delete</a></li>
	    			</ul>
		    	</div>
	 				<div class="content_title"><a href="#"><%=rs5.getString("memo_title") %></a></div>
	 			</li>
	 		<%
	 					}
	 				}
	 			} catch(SQLException e) {
	 				out.print(e);
	 			} finally {
					pstmt5.close();
					rs5.close();
					pstmt6.close();
					rs6.close();
	 			}
	 		}
	 		
		}
		%>
		</ul>
		</div>
		
			
		</div>
		
	</div>
	
	<footer>
	</footer>
	
<%con.close(); %>

</body>
</html> 