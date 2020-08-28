<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
	<title>Home</title>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</head>
<body>

	<button id="button" onclick="createOffer()">Offer:</button>
	<textarea id="offer" placeholder="Paste offer here"></textarea>
	Answer: <textarea id="answer"></textarea><br><div id="div"></div>
	
	<div>
		<form id="fileInfo">
			<input type="file" id="fileInput" name="files"/>
		</form>
		<button disabled id="sendFile">Send</button>
    </div>
	<div id="bitrate"></div>
	<a id="download"></a>
	<span id="status"></span>
	
	Chat: <input id="chat"><br>


<script>
	const config = {iceServers: [{urls: "stun:stun.1.google.com:19302"}]}; // google의 공개 stun 서버 중 하나
	const pc = new RTCPeerConnection(config); // 로컬과 원격 피어 간 연결 나타내는 새로운 객체 생성 반환
	const dc = pc.createDataChannel("chat", {negotiated: true, id: 0}); // 원격 유저와 연결하는 신규 채널 생성 (채널이름, 설정 옵션)
	const log = function(msg) {
		div.innerHTML += "<br>"+msg;
	}
	
	
	
	dc.onopen = function() { // 연결 및 데이터 요청(연결 성공했을 때, connected 됐을 때)
		chat.select();	
	} 
	dc.onmessage = function(e) { // 요청 데이터 받아와 사용
		log(">"+ e.data);	
	} 
	pc.oniceconnectionstatechange = function(e) { // 연결 상태
		log(pc.iceConnectionState);
	} 
	
	chat.onkeypress = function(e) {
		if (e.keyCode != 13) return;
		dc.send(chat.value); // 데이터 송수신 함수
		log(chat.value);
		chat.value = "";
	};
	
	/* async function createOffer() { */
	function createOffer() {
		button.disabled = true;
		/* await pc.setLocalDescription(await pc.createOffer()); */
		(function() {
			pc.setLocalDescription(function() { // 로컬 SDP 설명 설정
				pc.createOffer();  // 로컬 SDP 설명 작성
			});
		})();
		
		pc.onicecandidate = function(e) { // 로컬 ice 에이전트가 시그널링 서버를 통해 원격 피어에게 메세지 전달할 때마다 발생
			if (e.candidate) return; // candidate : 해당 candidate에 대한 네트워크 연결 정보.
			var a = pc.localDescription.sdp;
			$("#sdp").attr("value", a);
			offer.value = pc.localDescription.sdp; // sdp : session description protocol. 데이터의 해상도, 형식, 코덱 등 기술하는 표준이며 메타데이터
			offer.select();
			answer.placeholder = "Paste answer here";
		};
	}
	
	/* offer.onkeypress = async function(e) { */
	offer.onkeypress = function(e) {
		if (e.keyCode != 13 || pc.signalingState != "stable") return; // stable : 현재 진행중인 제안 및 답변 교환 없음. 또는 연결 이미 완료
		button.disabled = offer.disabled = true;
		
		/* await pc.setRemoteDescription({type: "offer", sdp: offer.value}); */
		(function() {
			pc.setRemoteDescription({type: "offer", sdp: offer.value});
		})();
		
		/* await pc.setLocalDescription(await pc.createAnswer()); */
		(function() {
			pc.setLocalDescription(function() {
				pc.createAnswer(); // 응답 sdp 생성.
			});
		})();
		
		pc.onicecandidate = function(e) {
			if (e.candidate) return;
			answer.focus();
			answer.value = pc.localDescription.sdp;
			answer.select();
		};
	};
	
	answer.onkeypress = function(e) {
		if (e.keyCode != 13 || pc.signalingState != "have-local-offer") return;
		answer.disabled = true;
		pc.setRemoteDescription({type: "answer", sdp: answer.value}); // 지정된 세션 설명을 원격 피어의 설명으로 설정.
	};
</script>
</body>
</html>
