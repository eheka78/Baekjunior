<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Baekjunior</title>
<link rel="stylesheet" href="Baekjunior_css.css">

<style>
	.ellipsis {
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}
</style>

</head>
<%
request.setCharacterEncoding("utf-8");
String userId = "none";
HttpSession session = request.getSession(false);
if(session != null && session.getAttribute("login.id") != null) {
	userId = (String) session.getAttribute("login.id");
}
else{
	response.sendRedirect("information.jsp");
    return;
}

// 기본 page type = 전체 문제 보기(all)
String pageType = request.getParameter("type");
if(pageType == null) pageType = "all";

// 모아볼(선택한) 난이도 분류
int levelSort = 0;
String tierNameSort = "";
int tierNumSort = 0;
if(pageType != null && "level".equals(pageType)) {
	levelSort = Integer.parseInt(request.getParameter("level"));
	tierNameSort = request.getParameter("tier_name");
	tierNumSort = Integer.parseInt(request.getParameter("tier_num"));
}

//모아볼(선택한) 알고리즘 분류
String algorithmSort = "";
if(pageType != null && "category".equals(pageType)) {
	algorithmSort = request.getParameter("sort");
}

//기본 SQL 쿼리 (검색어가 없을 경우 전체 검색)
String problemQuery = "SELECT * FROM problems WHERE user_id=?";
if(pageType != null && "bookmark".equals(pageType)) {
	problemQuery += "AND is_checked = 1";
} else if(pageType != null && "level".equals(pageType)) {
	problemQuery += "AND level=?";
} else if(pageType != null && "category".equals(pageType)) {
	// 특정 유저가 푼 문제 중, 특정 알고리즘 분류(sort = algorithm_sort 테이블에 존재)를 가진 문제들만 모아보기 
	problemQuery = "SELECT * FROM problems p JOIN algorithm_sort a ON p.problem_idx=a.problem_idx " 
				+ "WHERE a.user_id=? AND a.sort=?";
}

// 정렬 순서 정하기
// 주의 : 알고리즘 분류별로 모아볼 때는 p.problem_idx 명시 (기본 최신순)
String sortClause = "problem_idx DESC"; // 기본 최신순
if("category".equals(pageType)) 
	sortClause = "p.problem_idx DESC";	
	
if (request.getParameter("latest") != null) {
	sortClause = "problem_idx DESC";	// 최신순
	if("category".equals(pageType)) 
		sortClause = "p.problem_idx DESC";
} else if (request.getParameter("earliest") != null) {
	sortClause = "problem_idx";	// 오래된 순
	if("category".equals(pageType)) 
		sortClause = "p.problem_idx";
} else if (request.getParameter("ascending") != null) {
	sortClause = "problem_id";	// 문제번호 오름차순
} else if (request.getParameter("descending") != null) {
	sortClause = "problem_id DESC";	// 문제번호 내림차순
}

// 문제 검색하기
String searchRange = request.getParameter("search_range");
String searchKeyword = request.getParameter("search_keyword");

if (searchKeyword != null && !searchKeyword.isEmpty()) {	
	//searchKeyword = StringEscapeUtils.escapeHtml4(searchKeyword);
    searchKeyword = searchKeyword.replace(" ", ""); // 검색어에서 공백 제거
    // 특수 문자로 구분하기 위해 앞에 [\] 를 붙여 이스케이프 처리
    //searchKeyword = searchKeyword.replace("\\", "\\\\").replace("+", "\\+").replace("-", "\\-");
    
    if ("number".equals(searchRange)) {
        // 문제 번호로 검색
        problemQuery += " AND REPLACE(problem_id, ' ', '') LIKE ?";
    } else if ("title".equals(searchRange)) {
        // 제목으로 검색
        problemQuery += " AND REPLACE(memo_title, ' ', '') LIKE ?";
    } else if ("note".equals(searchRange)) {
        // 메모 내용으로 검색
        problemQuery += " AND REPLACE(main_memo, ' ', '') LIKE ?";
    }
}

problemQuery += " ORDER BY is_fixed DESC, " + sortClause;

Connection con = DsCon.getConnection();

PreparedStatement problemPstmt = null;
ResultSet problemRs = null;

PreparedStatement problemCountPstmt = null;
ResultSet countRs = null;

PreparedStatement categoryPstmt = null;
ResultSet categoryRs = null;

PreparedStatement levelPstmt = null;
ResultSet levelRs = null;
%>

<script type="text/javascript">
	// 진짜 삭제할건지 확인하는 함수
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

<body>	
	<header style="padding:0 100px;">
		<a href="index.jsp" class="logo">Baekjunior</a>
		<div id="main_menu">
			<ul>
				<li class="main_menu_Storage"><a href="#">Storage</a>
					<ul>
						<li><a href="index.jsp">ALL</a></li>
						<li><a href="1_Baekjunior.jsp">BOOKMARK</a></li>
						<li><a href="2_Baekjunior.jsp">CATEGORY</a></li>
						<li><a href="3_Baekjunior.jsp">LEVEL</a></li>
					</ul>
				</li>				
				<li class="main_menu_Friend"><a href="friend.jsp">Friend</a>
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
				<li class="main_menu_MyPage"><a href="MyPage.jsp">MyPage</a>
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
	
	
	
	<!-- menu -->
	<nav>
		<div>
			<ul>
				<li><a href="index.jsp"><b>ALL</b></a></li>
				<li><a href="index.jsp?type=bookmark">BOOKMARK</a></li>
				<li><a href="#">LEVEL</a>
					<ul class="sub" style="font-size:17px;">
					<%
						String levelQuery = "SELECT DISTINCT tier_name, tier_num, level FROM problems WHERE user_id=? ORDER BY level";
						levelPstmt = con.prepareStatement(levelQuery);
						levelPstmt.setString(1, userId);
						levelRs = levelPstmt.executeQuery();
						while(levelRs.next()){
							String tierName = levelRs.getString("tier_name");
							int tierNum = levelRs.getInt("tier_num");
							int level = levelRs.getInt("level");
							if(tierName.equals("unrated")) {
					%>
						<li><a href="index.jsp?type=level&level=<%=level%>&tier_name=<%=tierName%>&tier_num=<%=tierNum%>"><span><img src="img/star_<%=tierName.toLowerCase()%>.png"></span><span><%=tierName.toUpperCase()%></span></a></li>
					<%
							} else {
					%>
						<li><a href="index.jsp?type=level&level=<%=level%>&tier_name=<%=tierName%>&tier_num=<%=tierNum%>"><span><img src="img/star_<%=tierName.toLowerCase()%>.png"></span><span><%=tierName.toUpperCase()%><%=tierNum %></span></a></li>
					<%
							}
						}
					%>
					</ul>
				</li>
				<li><a href="#">CATEGORY</a>
					<ul class="sub" style="font-size:17px;">
					<%
						String categoryQuery = "SELECT * FROM algorithm_memo WHERE user_id=?";
						categoryPstmt = con.prepareStatement(categoryQuery);
						categoryPstmt.setString(1, userId);
						categoryRs = categoryPstmt.executeQuery();
						while(categoryRs.next()) {
					%>
						<li><a href="index.jsp?type=category&sort=<%=categoryRs.getString("algorithm_name")%>"><span><img src="img/dot1.png"></span><span><%=categoryRs.getString("algorithm_name") %></span></a></li>
					<%
						}
					%>
					</ul>
				</li>
			</ul>
			<br><br><br>
		</div>
	</nav>
	
	<div id="main">
		<div id="main_bar">
		<% 
			if("bookmark".equals(pageType)) { 
		%>
				<div style="font-size:30px; font-weight:bold; margin-bottom:50px;">BOOKMARK</div>
		<% 
			} else if("level".equals(pageType)) {
		%>
				<div style="font-size:30px; font-weight:bold; margin-bottom:50px;">
		<%
				if(tierNameSort.equals("unrated")) { 
		%>
					LEVEL : <%=tierNameSort.toUpperCase()%></div>
		<% 
				} else { 
		%>
					LEVEL : <%=tierNameSort.toUpperCase()%><%=tierNumSort %></div>
		<% 
				} 
			} else if("category".equals(pageType)) {
		%>
				<div style="margin-bottom:50px;display:flex;" >
					<a style="font-size:30px; font-weight:bold;"" onclick="location.href='algorithm_note.jsp?algorithm_sort=<%=algorithmSort%>'">
					CATEGORY : <%=algorithmSort %></a>
					<!-- 해당 알고리즘 노트 리스트는 오른쪽으로 밀리고 왼쪽에 알고리즘노트 나오는 버튼 -->
					<button class="memobutton" id="openmemo" onclick="openmemo()">memo</button>
					<button class="memobutton" id="closememo" onclick="closememo()" style="display:none;">close</button>
					
					<script>
					function openmemo() {
						document.getElementById("memo").style.display = "block";
						document.getElementById("openmemo").style.display = "none";
						document.getElementById("closememo").style.display = "block";
					}
					function closememo() {
						document.getElementById("memo").style.display = "none";
						document.getElementById("openmemo").style.display = "block";
						document.getElementById("closememo").style.display = "none";
					}
					</script>
				</div>
		<%
			}
		%>
			<div id="sort"  class="content_set">
				<div id="sort_select" class="content_set_b">
					<button>SORT</button>
				</div>
				<ul style="top:205px;">
				<!-- 페이지 타입에 따라 인자 전달을 다르게 함 -->
		<%
			if("all".equals(pageType) || "bookmark".equals(pageType)) {
		%>
					<li><a href="index.jsp?type=<%=pageType%>&latest=true&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Latest</a></li>
					<li><a href="index.jsp?type=<%=pageType%>&earliest=true&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Earliest</a></li>
					<li><a href="index.jsp?type=<%=pageType%>&ascending=true&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Ascending number</a></li>
					<li><a href="index.jsp?type=<%=pageType%>&descending=true&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Descending number</a></li>
		<%
			} else if("level".equals(pageType)) {
		%>
					<li><a href="index.jsp?type=level&latest=true&level=<%=levelSort%>&tier_name=<%=tierNameSort%>&tier_num=<%=tierNumSort%>&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Latest</a></li>
					<li><a href="index.jsp?type=level&earliest=true&level=<%=levelSort%>&tier_name=<%=tierNameSort%>&tier_num=<%=tierNumSort%>&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Earliest</a></li>
					<li><a href="index.jsp?type=level&ascending=true&level=<%=levelSort%>&tier_name=<%=tierNameSort%>&tier_num=<%=tierNumSort%>&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Ascending number</a></li>
					<li><a href="index.jsp?type=level&descending=true&level=<%=levelSort%>&tier_name=<%=tierNameSort%>&tier_num=<%=tierNumSort%>&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Descending number</a></li>
		<%
			} else if("category".equals(pageType)) {
		%>
					<li><a href="index.jsp?type=category&latest=true&sort=<%=algorithmSort%>&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Latest</a></li>
					<li><a href="index.jsp?type=category&earliest=true&sort=<%=algorithmSort%>&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Earliest</a></li>
					<li><a href="index.jsp?type=category&ascending=true&sort=<%=algorithmSort%>&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Ascending number</a></li>
					<li><a href="index.jsp?type=category&descending=true&sort=<%=algorithmSort%>&search_range=<%=searchRange%>&search_keyword=<%=searchKeyword%>">Descending number</a></li>
		<%
			}
		%>
				</ul>
			</div>
			
			<div id="search">
				<div id="search_frame" style="float:right;">
					<!-- 입력받은 검색어가 없으면, ""(placeholder 사용) 있으면, value = Util.nullchk(searchKeyword) 띄움 -->
					<input id="search_input" type="text"
    				<%= Util.nullchk(searchKeyword).isEmpty() ? "" : "value='" + Util.nullchk(searchKeyword) + "'" %> 
   				 													placeholder="Search...">
					<span><img src="img/search.png" style="width:15px;" onclick="searchNotes()"></span>
				</div>
				<!-- number로 검색하거나, 검색을 하지 않은 경우 number에 checked -->
				<div id="search_selection" style="float:right;">
					<input type="radio" name="search_range" value="number" 
					<%
				    	if (searchRange == null || "number".equals(searchRange)) {
				    %> 
				    	checked 
				    <%
				    	}
				    %>></input><label>Number</label>
					<input type="radio" name="search_range" value="title"
					<%
				    	if ("title".equals(searchRange)) {
				    %> 
				    	checked 
				    <%
				    	}
				    %>></input><label>Title</label>
					<input type="radio" name="search_range" value="note"
					<%
				   		if ("note".equals(searchRange)) {
				    %> 
				    	checked 
				    <%
				    	}
				    %>></input><label>Note</label>
				</div>
			</div>
			<div id="btn_cretenote">
				<button onclick="location.href='create_note.jsp'">CREATE NOTE</button>
			</div>
		</div>
		
		<script>
		function searchNotes() {
			// 사용자가 입력한 검색어 받아옴. 불필요한 공백 제거
	        var searchKeyword = document.getElementById("search_input").value.trim().replace(/\s+/g, '');
	        // 라디오 버튼 중, checked 상태인 놈을 고름
	        var searchRange = document.querySelector('input[name="search_range"]:checked').value;
		
	        // 검색어가 없으면 페이지 이동 x
	        if(searchKeyword === "") return;
	        
	        var page_type = "<%=pageType%>";
	        if("all" === page_type || "bookmark" === page_type) {
	        	window.location.href = 'index.jsp?type=' + page_type 
	        						+ '&search_range=' + searchRange + '&search_keyword=' + searchKeyword;
	        }
	        if("level" === page_type) {
	        	window.location.href = 'index.jsp?type=' + page_type 
	        					+ '&level=<%=levelSort%>&tier_name=<%=tierNameSort%>&tier_num=<%=tierNumSort%>'
								+ '&search_range=' + searchRange + '&search_keyword=' + searchKeyword;	
	        }
	        if("category" === page_type) {
	        	window.location.href = 'index.jsp?type=' + page_type 
				+ '&sort=<%=algorithmSort%>&search_range=' + searchRange + '&search_keyword=' + searchKeyword;
	        }
	    }
		</script>
		
		<br><br><br>
		
		<% if("category".equals(pageType)) { %>
		<div style="display:flex;margin-left:55px;">
			 <div class="memo" id="memo" style="margin-top:20px;flex:4;animation-name:takent;animation-duration:2s;display:none;">
               <div class="memo_box" contenteditable="true" id="editablememo" style="min-height:600px;padding:30px;background:white;border-radius:10px;border:3px solid black;">
                  <%
                  	String memoSql = "SELECT * FROM algorithm_memo WHERE user_id=? AND algorithm_name=?";
	                PreparedStatement memoPstmt = null;
	                ResultSet memoRs = null;
                  	memoPstmt = con.prepareStatement(memoSql);
                  	memoPstmt.setString(1, userId);
                  	memoPstmt.setString(2, algorithmSort);
                  	
                  	memoRs = memoPstmt.executeQuery();
                  	if(memoRs.next()) {
                  %>
                  	<%=Util.nullChk(memoRs.getString("algorithm_memo"), "not exist")%>
                  <% 
                  	} 
                  	memoPstmt.close();
                  	memoRs.close();
                  %>
               </div>
               
               <!-- editablememo 내용 수정할때마다 받아오기 -->
               <script>
                  const editablememo = document.getElementById('editablememo');
                  
                  // 텍스트가 수정될 때마다 발생하는 이벤트 리스너 추가
                  editablememo.addEventListener('input', function() {
                     //변경된 텍스트 받아오기
                     const editedtext = this.innerText;
                     console.log('변경된 텍스트: ', editedtext);
                  })
                  editablememo.addEventListener('focusout', function() {
                      console.log('포커스를 잃었습니다.');
                      // 사용자가 메모box를 벗어나면 db에 저장
                      
	                  const xhr = new XMLHttpRequest();
	                  const userId = '<%= userId %>'; // 세션에서 가져온 사용자 ID
	                  const algorithmSort = '<%= algorithmSort %>'; // 문제의 알고리즘 분류
	                  const editedtext = editablememo.innerText	; // 현재 수정된 텍스트
	
	                  xhr.open("POST", "algorithm_note_modify.jsp", true);
	                  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	                  xhr.onreadystatechange = function () {
	                      if (xhr.readyState === 4 && xhr.status === 200) {
	                          console.log("Response from server: ", xhr.responseText);
	                       }
	                  };
	
	                  // 파라미터로 userId, algorithmSort, 수정된 메모를 전송
	                  xhr.send("user_id=" + encodeURIComponent(userId) + "&algorithm_name=" + encodeURIComponent(algorithmSort) + "&algorithm_memo=" + encodeURIComponent(editedtext));
	                  });
                  
               </script>
            </div>
		<% 
			}
		%>
		
		<% if("category".equals(pageType)) { %>
			<div id="list_group" style="flex:6;">
				<ul class="list" style="margin: 20px 0 0 0;">
		<%
		} else {
		%>
			<div id="list_group">
			<ul class="list">
		<%
			}
		%>
 		<%
 		if (!userId.equals("none")) {
 			try {
 				// 문제 목록 select 하는 쿼리문 작성
 				problemPstmt = con.prepareStatement(problemQuery);
 				problemPstmt.setString(1, userId);
 				
 				if("level".equals(pageType)) {
 					problemPstmt.setInt(2, levelSort);
 	 				// 검색어가 있을 경우 쿼리에 파라미터 설정
 					if (searchKeyword != null && !searchKeyword.isEmpty()) {
 	 				    problemPstmt.setString(3, "%" + searchKeyword + "%");
 	 				}
 				} else if("category".equals(pageType)) {
 					problemPstmt.setString(2, algorithmSort);
 		 			if (searchKeyword != null && !searchKeyword.isEmpty()) {
 	 				    problemPstmt.setString(3, "%" + searchKeyword + "%");
 	 				}
 				} else {
 	 				if (searchKeyword != null && !searchKeyword.isEmpty()) {
 	 				    problemPstmt.setString(2, "%" + searchKeyword + "%");
 	 				}
 				}

 				problemRs = problemPstmt.executeQuery();
 				
 				int resultCount = 0;
 				while (problemRs.next()) {
 				    resultCount++;
 				}

 				// 검색 결과에 따라 출력 내용 결정
 				if (resultCount > 0) {
 					problemRs.beforeFirst();
 					while (problemRs.next()) {
 		%>
 			<li class="item">
 				<div class="content_number"><a href="note.jsp?problem_idx=<%=problemRs.getInt("problem_idx")%>"># <%=problemRs.getInt("problem_id") %></a></div>
 				<div class="content_set">
 				<!-- 고정 핀 아이콘 출력 여부 -->
 				<% if(problemRs.getInt("is_fixed") == 1) { %>
	    			<img class="content_set_a" id="content_set_a_<%= problemRs.getInt("problem_idx") %>" src="img/pin.png">
	    		<% } else { %>
	    			<img class="content_set_a" id="content_set_a_<%= problemRs.getInt("problem_idx") %>" src="img/pin.png" style="display:none">
	    		<% } %>
	    		<button class="content_set_b"><img src="img/....png"></button>
	    		<ul>
	    			<li><a onclick="updatePin('<%=problemRs.getInt("problem_idx") %>')" href="#">Unpin / Pin to top</a></li>
	    			<li><a href="split_screen.jsp?problem_idx1=<%=problemRs.getInt("problem_idx")%>&problem_idx2=-1">Split screen</a></li>
	    			<li><a href="#">Setting</a></li>
	    			<li><a onclick="confirmDeletion('<%=problemRs.getInt("problem_idx") %>')" href="#">Delete</a></li>
	    		</ul>
	    	</div>
 				<div class="content_title area ellipsis"><a href="note.jsp?problem_idx=<%=problemRs.getInt("problem_idx")%>"><%=problemRs.getString("memo_title") %></a></div>
 			</li>
 		<%
 					}			
 				} else {
 		%>
 			 <div>
 				not exist
 			</div>
 		<%		}
 			} catch(SQLException e) {
 				out.print(e);
 			} finally {
 				if(con != null) con.close();
				if(countRs != null) countRs.close();
				if(levelPstmt != null) levelPstmt.close();
				if(levelRs != null) levelRs.close();
				if(categoryPstmt != null) categoryPstmt.close();
				if(categoryRs != null) categoryRs.close();
				if(problemPstmt != null) problemPstmt.close();
				if(problemRs != null) problemRs.close();
				if(problemCountPstmt != null) problemCountPstmt.close();
				/* if(memoPstmt != null) memoPstmt.close();
				if(memoRs != null) memoRs.close(); */
 			}
 		}
 		%>
 		<% if("category".equals(pageType)) { %>
				</li>
		<% } %>
			</ul>
		</div>
	</div>
	
	<br><br><br>

	<footer></footer>

</body>
</html> 