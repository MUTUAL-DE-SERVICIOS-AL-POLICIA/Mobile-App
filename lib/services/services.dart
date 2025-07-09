import 'package:flutter_dotenv/flutter_dotenv.dart';

bool stateApp() => dotenv.env['STATE_PROD']=='true';


String? hostPVT = stateApp()? dotenv.env['HOST_PVT_PROD']: dotenv.env['HOST_PVT_DEV'];

String? hostSTI = stateApp()? dotenv.env['HOST_STI_PROD']: dotenv.env['HOST_STI_DEV'];

String? hostGATEWAY = stateApp()? dotenv.env['HOST_GATEWAY_PROD']: dotenv.env['HOST_GATEWAY_DEV'];

String? reazon = dotenv.env['reazon'];//v1
String? reazonAffiliate = dotenv.env['reazonAffiliate'];//affiliate
String? reazonQr = dotenv.env['reazonQr'];//global
String? reazonMovil = dotenv.env['reazonMovil'];//appmovil

//AUTH
String serviceAuthSession(int? affiliateId) => '$hostPVT/$reazon/auth/${affiliateId??''}';
//CONTACTS
String serviceGetContacts() => '$hostPVT/$reazon/city';
//CREDENTIALS "CIUDADANIA DIGITAL"
// String serviceGetCredentials() => '$hostGATEWAY/$reazonMovil/credentials';
String serviceGetCredentials() => '$hostSTI/$reazonAffiliate/assignmentcredentials';
String serviceVerificationCode() => '$hostSTI/$reazonAffiliate/verificationcode';
//PRIVACY POLICY
String serviceGetPrivacyPolicy() => 'https://www.muserpol.gob.bo/index.php/transparencia/terminos-y-condiciones-de-uso-aplicacion-movil';
//HISTORY
String serviceGetEconomicComplements(int page, bool current) =>
    '$hostPVT/$reazon/economic_complement/?page=$page&current=$current';
//GET VERIFIED DOCUMENT
String serviceGetMessageFace() => '$hostPVT/$reazon/message/verified';
//GET PROCESS ENROLLED
String serviceProcessEnrolled(String? deviceId) => '$hostPVT/$reazon/liveness/${deviceId!=null?'?device_id=$deviceId':''}';
//GET PERMISION PROCEDURE
String serviceGetProcessingPermit(int affiliateId) => '$hostPVT/$reazon/liveness/$affiliateId';
//SEND IMAGES FOR PROCEDURE
String serviceSendImagesProcedure() => '$hostPVT/$reazon/economic_complement';
//PRINT ECONOMIC COMPLEMENT
String serviceGetPDFEC(int economicComplementId) =>
    '$hostPVT/$reazon/economic_complement/print/$economicComplementId';
//GET OBSERVATIONS
String serviceGetObservation(int affiliateId) =>
    '$hostPVT/$reazon/affiliate/$affiliateId/observation';
String serviceEcoComProcedure(int ecoComId) => '$hostPVT/$reazon/eco_com_procedure/$ecoComId';
//GET VERSION
String servicePostVersion()=>'$hostPVT/$reazon/version';
//////////////////////////////////////////////////
/////////////OFICINA VIRTUAL/////////////////////
////////////////////////////////////////////////
// QR
String serviceGetQr(String info)=> '$hostSTI/$reazonQr/procedure_qr/$info';
// AUTH
String serviceAuthSessionOF()=>'$hostSTI/$reazonAffiliate/auth';
String createtosendmessage() =>'$hostSTI/$reazonAffiliate/sendcode';
String verifytosendmessage() =>'$hostSTI/$reazonAffiliate/verifycode';
// CHANGE PASSWORD
String serviceChangePasswordOF()=>'$hostSTI/$reazonAffiliate/change_password';
// FORGOT PASSWORD
String serviceForgotPasswordOF()=>'$hostSTI/app/send_code_reset_password';
// FORGOT PASSWORD SEND CODE
String serviceSendCodeOF()=>'$hostSTI/app/reset_password';
//////////////////////////////////////////////////
/////////////APORTES/////////////////////
////////////////////////////////////////////////

// APORTES
String serviceContributions(int affiliateId)=>'$hostSTI/app/all_contributions/$affiliateId';
//PRINT APORTES PASIVO
String servicePrintContributionPasive(int affiliateId)=>'$hostSTI/app/contributions_passive/$affiliateId';
//PRINT APORTES ACTIVO
String servicePrintContributionActive(int affiliateId)=>'$hostSTI/app/contributions_active/$affiliateId';

//////////////////////////////////////////////////
/////////////PRSTAMOS/////////////////////
////////////////////////////////////////////////

//PRESTAMOS
String serviceLoans(int affiliateId)=> '$hostSTI/app/get_information_loan/$affiliateId';
//PRINT PLAN DE PAGOS
String servicePrintLoans(int loanId)=> '$hostSTI/app/loan/$loanId/print/plan';
//PRINT KARDEX
String servicePrintKadex(int loanId)=>'$hostSTI/app/loan/$loanId/print/kardex';