<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<%
request.setCharacterEncoding("utf-8"); 
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>create_note</title>
<link rel="stylesheet" href="Baekjunior_css.css">
</head>
<script>
document.addEventListener("DOMContentLoaded", function() {
    let languageSelect = document.querySelector('select[name="language"]');
    let otherSpan = document.getElementById("language_other");

    if (languageSelect) {
        languageSelect.addEventListener("change", function() {
            if (this.value === "other") {
                otherSpan.style.display = "inline-block";
            } else {
                otherSpan.style.display = "none";
            }
        });
    }
});


function fnCheck(btn) {
    var problemId = document.getElementById("problemId");
    var code_note = document.getElementById("code_note");
    var importCheck = document.getElementById("importCheck");
    var problemTitle = document.getElementById("title");
    var language = document.getElementById("language");
    var languageOther = document.getElementById("language_others");
    var form = document.querySelector('form');

    if(problemId.value == "") {
        alert("문제 번호를 입력하세요.");
        return false;
    }
    else if(importCheck.value == "0") {
        alert("문제가 import 되지 않았습니다.");
        return false;
    }
    else if(problemTitle.value == "not_found") {
    	alert("존재하지 않는 문제 번호입니다.");
    	return false;
    }
    else if(language.value == "other" && languageOther.value == "") {
    	alert("언어를 입력하세요.");
    	return false;
    }
    else if(code_note.value == "") {
        alert("코드를 입력하세요.");
        return false;
    }

    if(btn === 'save_and_note'){
        form.action = 'note_save.jsp?open_note=true'; // Save and Note 버튼 클릭 시
    } else if(btn === 'save'){
        form.action = 'note_save.jsp?open_note=false'; // Save 버튼 클릭 시
    }
    
    form.submit(); // 폼 제출
}

function resetImportCheck() {
	document.getElementById("importCheck").value = "0";
}
function importClick() {
    var problemId = document.getElementById("problemId").value;
    
    if (problemId) {
        location.href = 'create_note.jsp?problemId=' + encodeURIComponent(problemId);
    } else {
        alert("문제 번호를 입력하세요.");
    }
    return false; // 문제 정보 가져오기만 하고 제출은 x
}
</script>
<%
ProblemInfoGet getPI = new ProblemInfoGet();
String problemId = request.getParameter("problemId"); // 문제 번호 입력 받기
String userId = "none";
String title = "";
String url = "";
String algorithms = "";
int level = 0;
String tier_name = "";
int tier_num = 0;

if (problemId != null && !problemId.isEmpty()) {
    // 문제 정보를 가져오는 메서드 호출
    title = getPI.getTitle(problemId);
    if (title.equals("not_found")) {
        out.println("<script>alert('존재하지 않는 문제입니다.');</script>");
    } else {
        url = getPI.getProblemURL(problemId);
        algorithms = getPI.getAlgorithms(problemId);
        level = getPI.getLevel(problemId);
        tier_name = getPI.getTierName();
        tier_num = getPI.getTierNum();
	}
}

HttpSession session = request.getSession(false);
if(session != null) {
	userId = (String) session.getAttribute("login.id");
}
else{
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
				<li><a href="MyPage.jsp"><%=userId %></a></li>
			</ul>
			<div id="myprodiv" onmouseover="opendiv()" onmouseout="closediv()" style="display:none;position:fixed;top: 100px;background: white;padding: 17px;border: 3px solid black;margin-right: 20px;width: 200px;">
				<div id="myprofileimgborder">
					<img id="myprofileimg" src="./upload/<%=rs.getString("savedFileName") %>" alt="profileimg">
				</div>
				<a href="MyPage.jsp" style="position:absolute;top:30px;margin-left:90px;text-decoration: none;color: black;"><%=userId %></a>
				<a href="logout_do.jsp" style="border: 1px solid;width: 90px;display:inline-block;text-align: center;height: 30px;position:absolute;top:60px;margin-left:78px;text-decoration: none;color: black;">로그아웃</a>
			</div>
		</div>
		<%
		con.close();
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
	
	<form action="#" method="post">
	<div style="margin-top:20px;">
		<div style="width:80%; margin:0 auto; border:3px solid black;">
			<div style="font-size:30px; font-weight:bold; padding:40px; padding-left:10px; padding-right:10px; border-bottom:3px solid black; background:#5F99EB">
				<img src="img/dot1.png" style="width:15px; margin:0 20px 0 40px; padding-bottom:3px;">
				Create Note : BAEKJOON
			</div>
			
			<br>
			
			<div style="padding:30px;">
				<div id="note_info">
					<input type="hidden" name="userId" id="userId" value="<%=userId%>"> 
					<input type="hidden" name="level" id="level" value="<%=level%>">
					<input type="hidden" name="tier_name" id="tier_name" value="<%=tier_name%>">
					<input type="hidden" name="tier_num" id="tier_num" value="<%=tier_num%>">
					<input type="hidden" name="problem_sort" id="problem_sort" value="<%=algorithms %>">
					<input type="hidden" name="importCheck" id="importCheck" value="0">
					<div>
						Problem Number :
						<span style="border-bottom:3px solid black;">
							<input type="text" id="problemId" name="problemId" value="<%=Util.nullChk(problemId, "") %>" oninput="resetImportCheck()" style="background:transparent; outline:none; border:none;">
						</span>
						<span><button type="button" style="font-size:15px; font-weight:bold; padding:5px 20px; background:white; border:3px soild black; margin-left:20px; cursor:pointer;"
								onclick="importClick()">import</button>
						</span>
					</div>
					<div>
						Problem Title :
						<span style="border-bottom:3px solid black;">
							<input type="text" id="title" name="title" value="<%=title%>" style="background:transparent; outline:none; border:none; width:50%;" readonly>
						</span>
					</div>
					<div>
						Note Title :
						<span style="border-bottom:3px solid black;">
							<input type="text" id="title" name="memo_title" value="<%=title%>" style="background:transparent; outline:none; border:none; width:50%;">
						</span>
					</div>
					<div>
						Problem URL :
						<span style="border-bottom:3px solid black;">
							<input type="text" id="problem_url" name="problem_url" value="<%=url%>" style="background:transparent; outline:none; border:none; width:50%;">
						</span>
					</div>
					<div>
						Problem Category :
						<div id="problem_category">
							<ul>
                                <%
                                    String[] algorithmList = algorithms.split(",");
                                	if(algorithms == null || algorithms.trim().isEmpty()) {
                                %>
	                                <li>
	                                    <input type="checkbox" name="sorts" id="check_btn" value="unsorted" checked onclick="return false"> unsorted
	                                </li>
                                <%	
                                	} else {
                                    for (String algo : algorithmList) {
                                        if (!algo.isEmpty()) {
                                %>
                                <li>
                                    <input type="checkbox" name="sorts" id="check_btn" value="<%=algo%>" checked onclick="return false"> <%= algo %>
                                </li>
                                <%
                                        }
                                    }
                                }
                                %>
							</ul>
						</div>
					</div>	
				</div>
				
				
			<div id="note">
				<div style="margin-top:20px;">
					Bookmark <input type="checkbox" name="check_btn" id="check_btn" value="1" style="cursor:pointer;">
				</div>
				<div>
					Code Language :
					<span>
					<select id="language" name="language" style="width:140px; text-align:center; font-size:18px; height:35px; cursor:pointer;">
					    <option value="C++">C++</option>
					    <option value="python">Python</option>
					    <option value="c#">C#</option>
					    <option value="java">Java</option>
						<option value="javascript">JavaScript</option>
					    <option value="other">other...</option>
					</select>
					</span>
					<span id="language_other" style="display:none;"><input type="text" id="language_others" name="language_other" style="font-size:18px; height:35px;"></span>
				</div>
				<div>Code</div>
				<div id="code-editor" style="display: grid; grid-template-columns: 1fr 20fr; border: none;">
			        <textarea id="lineNumbers" rows="10" wrap="off" style="font-size:15px; overflow:auto; text-align:center; padding-bottom:0px;" readonly></textarea>
			        <textarea id="code_note" name="code_note" rows="10" placeholder="Enter your code here..." wrap="off" style="font-size:15px; overflow-x:auto; padding-bottom:60px;"></textarea>
			    </div>
			</div>
			</div>
		</div>
	</div>
	
	<div style="width:80%; margin:0 auto; margin-top:30px;">
		<div style="float:right;">
			<button type="submit" style="font-size:15px; font-weight:bold;  background:white; border:3px solid black; padding:5px 20px; margin-right:10px;"
					onclick="return fnCheck('save_and_note')">
				Save and Note</button> 
			<button type="submit" style="font-size:15px; font-weight:bold;  background:white; border:3px solid black; padding:5px 20px;"
					onclick="return fnCheck('save')">Save</button>
		</div>
	</div>
</form>
	
	<!-- 역시 chatgpt -->
	<!-- 코드 입력창 -->
	<script>
	const textarea = document.getElementById('code_note');
    const lineNumbers = document.getElementById('lineNumbers');
    
	console.log(textarea);
    function updateLineNumbers() {
        const numberOfLines = textarea.value.split('\n').length;
        let lineNumberString = '';

        for (let i = 1; i <= numberOfLines; i++) {
            lineNumberString += i + '\n'
        }

        lineNumbers.value = lineNumberString;
    }

    function adjustHeight(element) {
        element.style.height = 'auto'; // Reset height to auto to measure scrollHeight
        element.style.height = element.scrollHeight + 'px'; // Adjust height to fit content
    }

    // Function to sync heights between textareas
    function syncHeights() {
        const maxScrollHeight = Math.max(textarea.scrollHeight, lineNumbers.scrollHeight);
        textarea.style.height = maxScrollHeight + 'px';
        lineNumbers.style.height = maxScrollHeight + 'px';
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
    
 	// problemId 가 입력되면 importCheck를 1로 업데이트
	<% if (problemId != null && !problemId.isEmpty()) { %>
    	document.addEventListener("DOMContentLoaded", function() {
        	document.getElementById('importCheck').value = '1';
    	});
	<% } %>
	
    function submitcode_note() {
        const code = textarea.value;
        console.log("Submitted Code:", code);

        // 서버에 코드를 전송하거나 WebAssembly로 처리하는 로직을 여기에 추가합니다.
    }
	</script>
	
	<br><br><br><br>

	<footer></footer>

</body>
</html> 