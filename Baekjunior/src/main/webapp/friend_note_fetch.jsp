<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>note</title>
<link rel="stylesheet" href="Baekjunior_css.css">

<style>
a{
	text-decoration: none;
	color:black;
}

 @-webkit-keyframes takent {
      0% {
         flex: 0;
      }
      100% {
         flex: 3;
      }
   }
   @keyframes takent {
      0% {
         flex: 0;
      }
      100% {
         flex: 3;
      }
   }
   @-webkit-keyframes outnt {
      0% {
         flex: 3;
      }
      100% {
         flex: 0;
      }
   }
   @keyframes outnt {
      0% {
         flex: 3;
      }
      100% {
         flex: 0;
      }
   }
   .outnote {
      animation-name: outnt;
      animation-duration: 2s;
   }
</style>


</head>
<%
request.setCharacterEncoding("utf-8");
String userId = "none";
HttpSession session = request.getSession(false);
log("CC: " + request.getParameter("friend") + " \nDD: " + request.getParameter("problem_idx"));

String friend = request.getParameter("friend");
int problemIdx = Integer.parseInt(request.getParameter("problem_idx"));


Connection con = DsCon.getConnection();
PreparedStatement pstmt = null;
ResultSet rs = null;
%>
<body>	
	
	<script type="text/javascript">
		window.addEventListener("scroll", function(){
			var header= document.querySelector("header");
			header.classList.toggle("sticky", window.scrollY > 0);
		});
	</script>
	<%
		try {
			String sql = "SELECT * FROM problems WHERE problem_idx=? AND user_id=?";
			
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, problemIdx);
			pstmt.setString(2, friend);
			rs = pstmt.executeQuery();
			if(rs.next()){
				
	%>

	<div style="margin-top:20px; width:100%;">
		<div style="width:80%; margin:0 auto;">
			<div>
				<div>
					<div style="display:inline; width:80%; font-size:30px; font-weight:bold;">
						#<span><%=rs.getInt("problem_id") %></span> : <span><%=rs.getString("problem_title") %></span> 
					</div>
					<div style="float:right; font-size:15px; padding:10px;">
						Submit Date : <span><%=rs.getDate("submitDate") %></span>
					</div>
				</div>
				
				<div style="font-weight:bold; font-size:18px; margin-top:15px; margin-left:20px;">
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
						%>
						<span style="margin-right:25px;"><img src="img/dot1.png" style="width:15px;"></span><span> default sort</span>
						<% } %>
					</div>
					<!-- 언어 종류 -->
					<div style="display:inline;">
						<span style="margin-right:50px;"><%=rs.getString("language") %></span>
					</div>
				</div>
			</div>	
			
			<div style="font-weight:bold; font-size:20px; border:3px solid black; background:#5F99EB; padding:30px; margin-top:50px; vertical-align:middle; ">
				<%
					String subMemoStr = rs.getString("sub_memo");
					String[] subMemos = subMemoStr != null ? subMemoStr.split("\n") : new String[]{};
					
					if(subMemoStr == null){
						%>
						<div>not exist</div><%
					}
					else{
				%>
					<% for (String memo : subMemos) { %>
						<div style="padding:5px;">
							<img src="img/arrow3.png" style="height:15px; margin-right:5px;"> <span><%=memo %></span>
						</div>
		        <% 	   }
					} %>
			</div>
			
			<div style="display: grid; margin-top: 50px; grid-template-columns: 5fr 2fr; column-gap: 30px;">
		        <div style="column-gap: 10px; border: 3px solid black; background: white; padding: 10px;">
		            <div id="code-editor" style="display: grid; grid-template-columns: 1fr 17fr; border: none;">
		                <textarea class="notes" id="lineNumbers" rows="10" wrap="off" style="font-size:15px; overflow:auto; text-align:center; padding-bottom:0px; " readonly></textarea>
		                <textarea class="notes" id="code_note" rows="10" placeholder="Enter your code here..." wrap="off" style="font-size:15px; overflow-x:auto; padding-bottom:60px;" readonly><%=Util.nullChk(rs.getString("code"), "") %></textarea>
		            </div>
		        </div>

       		 	<div style="column-gap: 10px; border: 3px solid black; background: white; padding: 10px;">
		            <div id="code-editor" style="border: none;">
		                <textarea class="notes" id="note_detail" rows="10" placeholder="Enter your note here..." wrap="off" style="font-size:15px; overflow-x:auto; padding-bottom:60px;" readonly><%=Util.nullChk(rs.getString("main_memo"), "") %></textarea>
		            </div>
        		</div>
    		</div>
		<%
			}
			con.close();
			pstmt.close();
			rs.close();
			
		} catch(SQLException e) {
 			out.print(e);
 			return;
 		}
		%>
		
		<script>
		const textarea = document.getElementById('code_note');
        const lineNumbers = document.getElementById('lineNumbers');
        
		console.log("AA: " + textarea);
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

        function submitcode_note() {
            const code = textarea.value;
            console.log("Submitted Code:", code);

            // 서버에 코드를 전송하거나 WebAssembly로 처리하는 로직을 여기에 추가합니다.
        }
    	</script>
		</div>
			
	</div>
	
	<br><br>

	<footer></footer>

</body>
</html> 