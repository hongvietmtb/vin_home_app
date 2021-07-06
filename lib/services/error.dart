String? serviceError(int errorCode){
	switch (errorCode){
		case 0:
			return "Success";
		default:
			return null;
	}
}