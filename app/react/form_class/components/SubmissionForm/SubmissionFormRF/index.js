import { reduxForm } from 'redux-form';
import SubmissionFormView from './SubmissionFormView';

const FORM = 'submission';

const validate = ({ firstName, lastName }) => {
  const errors = {};
  if (firstName === undefined) {
    errors.firstName = 'Required';
  } else if (firstName.trim() === '') {
    errors.firstName = 'Must not be blank';
  }
  if (lastName === undefined) {
    errors.lastName = 'Required';
  } else if (lastName.trim() === '') {
    errors.lastName = 'Must not be blank';
  }
  return errors;
};

const SubmissionFormRF = reduxForm({
  form: FORM,
  validate,
})(SubmissionFormView);

export default SubmissionFormRF;
