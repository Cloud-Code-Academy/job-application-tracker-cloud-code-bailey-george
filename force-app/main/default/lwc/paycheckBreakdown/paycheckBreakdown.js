import { LightningElement, track } from  'lwc';

export default class PaycheckBreakdown extends LightningElement {
   
    fedIncomeTaxWeight = 12;
    socialSecurityWeight = 6.2;
    medicareWeight = 1.45;
    salary = 0;
    takeHomePay = 0;
    monthlyTakeHomePay = 0;
    biWeeklyTakeHomePay = 0;
    weeklyTakeHomePay = 0;

    calculateSalary(){
        	
        let fedIncomeTaxRemoved = this.salary * (this.fedIncomeTaxWeight *.01);
        let socialSecurityRemoved = this.salary * (this.socialSecurityWeight * .01);
        let medicareRemoved = this.salary * (this.medicareWeight * .01);
        this.takeHomePay = (this.salary - (fedIncomeTaxRemoved + socialSecurityRemoved + medicareRemoved)).toFixed(2);

        this.monthlyTakeHomePay = (this.takeHomePay / 12).toFixed(2);
        this.biWeeklyTakeHomePay = (this.takeHomePay / 26).toFixed(2);
        this.weeklyTakeHomePay = (this.takeHomePay / 52).toFixed(2);
    }



    handleChange(event){
        const inputName = event.target.name;
        let value = Number(event.target.value);
        if(inputName === 'salary'){
            this.salary = value;
        } else if (inputName === 'federalIncomeTax'){
            this.fedIncomeTaxWeight = value;
        } else if (inputName === 'socialSecurity'){
            this.socialSecurityWeight = value;
        } else if (inputName === 'medicare'){
            this.medicareWeight = value;
        }
    }
}