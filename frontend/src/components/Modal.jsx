import PropTypes from "prop-types";

function Modal({ message, onClose }) {
  return (
    <div
      className="modal-overlay"
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-message"
    >
      <div className="modal-content">
        <p id="modal-message">{message}</p>

        <button type="button" onClick={onClose}>
          Close
        </button>
      </div>
    </div>
  );
}

Modal.propTypes = {
  message: PropTypes.string.isRequired,
  onClose: PropTypes.func.isRequired,
};

export default Modal;
