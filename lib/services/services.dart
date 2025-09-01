import 'package:flutter_dotenv/flutter_dotenv.dart';

bool stateApp() => dotenv.env['STATE_PROD'] == 'true';

//Eliminar rutas que dependan de hostPVT y hostSTI
// String? hostPVT =
//     stateApp() ? dotenv.env['HOST_PVT_PROD'] : dotenv.env['HOST_PVT_DEV'];

String? hostSTI =
    stateApp() ? dotenv.env['HOST_STI_PROD'] : dotenv.env['HOST_STI_DEV'];

String? hostGATEWAY = stateApp()
    ? dotenv.env['HOST_GATEWAY_PROD']
    : dotenv.env['HOST_GATEWAY_DEV'];

String? reazon = dotenv.env['reazon']; //v1
String? reazonAffiliate = dotenv.env['reazonAffiliate']; //affiliate
String? reazonQr = dotenv.env['reazonQr']; //global
String? reazonMovil = dotenv.env['reazonMovil']; //appmovil
String? auth = dotenv.env['auth'];

//AUTH CERRAR SESION POR EL MOMENTO
// String serviceAuthSession(int? affiliateId) => '$hostPVT/$reazon/auth/${affiliateId??''}';
String serviceAuthSession() => '$hostGATEWAY/$auth/logoutAppMobile';

//CONTACTS
// String serviceGetContacts() => '$hostPVT/$reazon/city';
String serviceGetContacts() => '$hostGATEWAY/$reazonMovil/globalCities';
//PRIVACY POLICY
String serviceGetPrivacyPolicy() =>
    'https://www.muserpol.gob.bo/index.php/transparencia/terminos-y-condiciones-de-uso-aplicacion-movil';

//CAMBIAR A MICRO SERVICIOS
//HISTORY
// String serviceGetEconomicComplements(int page, bool current) =>
//     '$hostPVT/$reazon/economic_complement/?page=$page&current=$current';

String serviceGetEconomicComplements(int page, bool current) =>
    '$hostGATEWAY/$reazonMovil/ecoComEconomicComplements/?page=$page&current=$current';
//GET VERIFIED DOCUMENT
// String serviceGetMessageFace() => '$hostPVT/$reazon/message/verified';

String serviceGetMessageFaceType(String type) =>
    '$hostGATEWAY/$reazonMovil/message/$type';
//GET PROCESS ENROLLED
// String serviceProcessEnrolled(String? deviceId) =>
//     '$hostPVT/$reazon/liveness/${deviceId != null ? '?device_id=$deviceId' : ''}';

String serviceProcessEnrolled() => '$hostGATEWAY/$reazonMovil/ecoComLiveness';

String serviceProcessEnrolledPost() =>
    '$hostGATEWAY/$reazonMovil/ecoComLivenessStore';
//GET PERMISION PROCEDURE
// String serviceGetProcessingPermit(int affiliateId) =>
//     '$hostPVT/$reazon/liveness/$affiliateId';

String serviceGetProcessingPermit(int affiliateId) =>
    '$hostGATEWAY/$reazonMovil/ecoComLivenessShow/$affiliateId';

//SEND IMAGES FOR PROCEDURE
// String serviceSendImagesProcedure() => '$hostPVT/$reazon/economic_complement';
String serviceSendImagesProcedure() =>
    '$hostGATEWAY/$reazonMovil/ecoComEconomicComplementsStore';
//PRINT ECONOMIC COMPLEMENT
// String serviceGetPDFEC(int economicComplementId) =>
//     '$hostPVT/$reazon/economic_complement/print/$economicComplementId';

String serviceGetPDFEC(int economicComplementId) =>
    '$hostGATEWAY/$reazonMovil/ecoComEconomicComplementsPrint/$economicComplementId';
//GET OBSERVATIONS
// String serviceGetObservation(int affiliateId) =>
//     '$hostPVT/$reazon/affiliate/$affiliateId/observation';

String serviceGetObservation(int affiliateId) =>
    '$hostGATEWAY/$reazonMovil/ecoComAffiliateObservations/$affiliateId';

// String serviceEcoComProcedure(int ecoComId) =>
//     '$hostPVT/$reazon/eco_com_procedure/$ecoComId';

String serviceEcoComProcedure(int ecoComId) =>
    '$hostGATEWAY/$reazonMovil/ecoComProcedure/$ecoComId';

//GET VERSION
// String servicePostVersion()=>'$hostPVT/$reazon/version';

String serviceVersion() => '$hostGATEWAY/$reazonMovil/version';

//AUTENTICACION DE USUARIO POR SMS
// String createtosendmessage() =>'$hostSTI/$reazonAffiliate/sendcode';
String loginAppMobile() => '$hostGATEWAY/$auth/loginAppMobile';
// String verifytosendmessage() =>'$hostSTI/$reazonAffiliate/verifycode';
String verifyPin() => '$hostGATEWAY/$auth/verifyPin';
// APORTES CON MICROSERVICIO "appMobile"
String serviceContributions(int affiliateId) =>
    '$hostGATEWAY/$reazonMovil/contributionsAll/$affiliateId';
// String serviceContributions(int affiliateId)=>'$hostSTI/app/all_contributions/$affiliateId';
//NO DIBUJA EL PDF
//PRINT APORTES PASIVO
String servicePrintContributionPasive(int affiliateId) =>
    '$hostGATEWAY/$reazonMovil/contributionsPassive/$affiliateId';
// String servicePrintContributionPasive(int affiliateId)=>'$hostSTI/app/contributions_passive/$affiliateId';
//PRINT APORTES ACTIVO
String servicePrintContributionActive(int affiliateId) =>
    '$hostGATEWAY/$reazonMovil/contributionsActive/$affiliateId';
// String servicePrintContributionActive(int affiliateId)=>'$hostSTI/app/contributions_active/$affiliateId';

//PRESTAMOS CON MICROSERVICIO "appMobile"

String serviceLoans(int affiliateId) =>
    '$hostGATEWAY/$reazonMovil/loanInformation/$affiliateId';
// String serviceLoans(int affiliateId)=> '$hostSTI/app/get_information_loan/$affiliateId';
//No dibuja el documento PDF
//PRINT PLAN DE PAGOS
// String servicePrintLoans(int loanId)=> '$hostSTI/app/loan/$loanId/print/plan';
String servicePrintLoans(int loanId) =>
    '$hostGATEWAY/$reazonMovil/loanPrintPlan/$loanId';
//PRINT KARDEX
// String servicePrintKadex(int loanId)=>'$hostSTI/app/loan/$loanId/print/kardex';
String servicePrintKadex(int loanId) =>
    '$hostGATEWAY/$reazonMovil/loanPrintKardex/$loanId';

//CREDENTIALS "CIUDADANIA DIGITAL -SERVICIO DE AUTENTICACION"
String serviceGetCredentials() =>
    '$hostSTI/$reazonAffiliate/assignmentcredentials';
String serviceVerificationCode() =>
    '$hostSTI/$reazonAffiliate/verificationcode';

//enviarfotografia
String sendIdentityCard() => '$hostGATEWAY/$reazonMovil/ecoComSaveIdentity';
